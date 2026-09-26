#!/usr/bin/env python3
"""
ClassicModels Query Challenge - synthetic dataset generator
============================================================
Builds a LARGE, realistic dataset that follows the classic `classicmodels`
schema (8 tables) and writes it in three formats:

    sql/02_data.sql             MySQL / MariaDB INSERT statements
    data/<table>.csv            one CSV per table
    sqlite/classicmodels.db     ready-to-query SQLite database

Everything is generated from a fixed random seed, so the same command always
produces exactly the same data.

Usage (from the project root):
    python3 scripts/generate_dataset.py                       # default size
    python3 scripts/generate_dataset.py --customers 5000 --orders 60000
    python3 scripts/generate_dataset.py --seed 7
"""
import argparse
import csv
import datetime as dt
import os
import random
import sqlite3
from bisect import bisect_left
from itertools import accumulate

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

ap = argparse.ArgumentParser()
ap.add_argument("--seed", type=int, default=20260924)
ap.add_argument("--customers", type=int, default=2500)
ap.add_argument("--orders", type=int, default=20000)
ap.add_argument("--products", type=int, default=500)
args = ap.parse_args()
random.seed(args.seed)

TODAY = dt.date(2026, 9, 24)          # "current date" of the dataset
FIRST_ORDER = dt.date(2022, 1, 3)
LAST_ORDER = dt.date(2026, 9, 22)


# ----------------------------------------------------------------- helpers
def wchoice(items, weights):
    return random.choices(items, weights=weights, k=1)[0]


def cents(x):
    return int(round(x * 100))


def money(c):
    return f"{c // 100}.{c % 100:02d}"


def sql_val(v):
    if v is None:
        return "NULL"
    if isinstance(v, bool):
        return "1" if v else "0"
    if isinstance(v, int):
        return str(v)
    if isinstance(v, dt.date):
        return f"'{v.isoformat()}'"
    s = str(v).replace("\\", "\\\\").replace("'", "''")
    return f"'{s}'"


class Money(str):
    """A pre-formatted decimal string that is emitted unquoted in SQL."""


def sql_row(row):
    out = []
    for v in row:
        out.append(str(v) if isinstance(v, Money) else sql_val(v))
    return "(" + ",".join(out) + ")"


# ----------------------------------------------------------------- lists
FIRST = ["Aiko", "Aisha", "Alejandro", "Alice", "Amelie", "Andrea", "Anders", "Anna", "Arjun", "Ben", "Bianca",
         "Boris", "Camille", "Carlos", "Chen", "Chloe", "Daniel", "David", "Diego", "Elena", "Emma", "Eric",
         "Fatima", "Felix", "Francois", "Gabriela", "Giovanni", "Hannah", "Hans", "Hiroshi", "Ingrid", "Isabella",
         "Jack", "Jacques", "Jamal", "Jane", "Javier", "Jean", "Jennifer", "Jin", "Joao", "Julia", "Kaito", "Karen",
         "Kenji", "Laura", "Lars", "Leila", "Liam", "Lucas", "Luca", "Maria", "Marco", "Mark", "Marta", "Mateo",
         "Matthew", "Mei", "Michael", "Mohammed", "Nadia", "Nina", "Noah", "Olga", "Omar", "Oscar", "Paul", "Peter",
         "Pierre", "Priya", "Rachel", "Rahul", "Raj", "Rosa", "Ryan", "Sakura", "Sara", "Sofia", "Sophie", "Stefan",
         "Sven", "Takeshi", "Thomas", "Tomas", "Valentina", "Victor", "Wei", "William", "Yuki", "Zoe", "Martin",
         "Marie", "Mason", "Megan", "Miguel", "Monica", "Marcus", "Ananya", "Vikram", "Deepa", "Sanjay"]
LAST = ["Adams", "Anderson", "Bauer", "Becker", "Bennett", "Berg", "Bianchi", "Brown", "Carter", "Chen", "Clark",
        "Costa", "Davis", "Dubois", "Dupont", "Evans", "Fernandez", "Fischer", "Garcia", "Gomez", "Gonzalez", "Green",
        "Gupta", "Hansen", "Harris", "Hernandez", "Hoffmann", "Huang", "Ito", "Jackson", "Jensen", "Johansson",
        "Johnson", "Jones", "Kato", "Kim", "King", "Klein", "Kowalski", "Kumar", "Lambert", "Larsen", "Lee", "Lewis",
        "Lopez", "Martin", "Martinez", "Meyer", "Miller", "Moreau", "Morgan", "Muller", "Murphy", "Nakamura", "Nelson",
        "Nguyen", "Nielsen", "Novak", "Olsen", "Patel", "Perez", "Petersen", "Reyes", "Ricci", "Roberts", "Rossi",
        "Roy", "Sanchez", "Sato", "Schmidt", "Schneider", "Scott", "Silva", "Singh", "Smith", "Suzuki", "Tanaka",
        "Taylor", "Thompson", "Torres", "Turner", "Vargas", "Wagner", "Walker", "Weber", "White", "Williams",
        "Wilson", "Wong", "Wright", "Yamamoto", "Young", "Zhang", "Reddy", "Iyer", "Nair", "Sharma", "Mehta"]
STREETS = ["Main Street", "High Street", "Park Avenue", "Oak Lane", "Maple Road", "Station Road", "Church Street",
           "Market Square", "River Road", "Sunset Boulevard", "Broadway", "King Street", "Queen Street", "Elm Street",
           "Harbour Way", "Mill Lane", "Victoria Road", "Lakeview Drive", "Industrial Estate", "Commerce Way"]
CUST_ADJ = ["Atelier", "Baroque", "Classic", "Corporate", "Diecast", "Euro", "Frontier", "Heritage", "Iconic", "Jade",
            "Kingdom", "Marquee", "Mini", "Noble", "Oasis", "Prestige", "Quality", "Royal", "Signal", "Vintage",
            "Western", "Xtreme", "Zenith", "Amica", "Cambridge", "Dragon", "Enthusiast", "Golden", "Harbour",
            "Imperial", "Lakeside", "Metro", "Northern", "Old Town", "Pioneer", "Rocket", "Silver", "Summit", "Urban",
            "Victory", "Sunset", "Crimson", "Emerald", "Falcon", "Granite", "Horizon", "Ivory", "Juniper", "Anchor",
            "Beacon", "Cobalt", "Delta", "Alpine", "Bluebird", "Cedar", "Driftwood"]
CUST_NOUN = ["Collectables", "Gifts", "Models", "Toys", "Hobbies", "Classics", "Miniatures", "Souvenirs", "Replicas",
             "Wheels", "Traders", "Emporium", "Imports", "Depot", "Boutique", "Gallery", "Designs", "Distributors",
             "Merchants", "Showroom", "Gift Shop", "Toy Store", "Auto Models", "Collectibles", "Scale Models",
             "Diecast Direct", "Gift Ideas", "Hobby House"]

# country -> weight, sales territory, cities(city,state), postal(), dial code, company suffixes
def _p5(): return f"{random.randint(10000, 99999)}"
def _p4(): return f"{random.randint(1000, 9999)}"
def _uk(): return f"{random.choice('BCEGLMNSW')}{random.randint(1, 9)} {random.randint(1, 9)}{random.choice('ABDEFGHJLNPQRSTUWXYZ')}{random.choice('ABDEFGHJLNPQRSTUWXYZ')}"
def _ca(): return f"{random.choice('KLMNPTV')}{random.randint(1, 9)}{random.choice('ABCEGHJKLMNPRSTVWXYZ')} {random.randint(1, 9)}{random.choice('ABCEGHJKLMNPRSTVWXYZ')}{random.randint(1, 9)}"
def _jp(): return f"{random.randint(100, 999)}-{random.randint(1000, 9999)}"
def _in(): return f"{random.randint(110000, 700000)}"

COUNTRIES = {
    "USA": (26, "NA", [("New York", "NY"), ("Los Angeles", "CA"), ("San Francisco", "CA"), ("Boston", "MA"),
                       ("Chicago", "IL"), ("Houston", "TX"), ("Dallas", "TX"), ("Miami", "FL"), ("Seattle", "WA"),
                       ("Philadelphia", "PA"), ("Las Vegas", "NV"), ("Portland", "OR"), ("Denver", "CO"),
                       ("Atlanta", "GA"), ("Phoenix", "AZ"), ("Minneapolis", "MN"), ("Nashville", "TN"),
                       ("San Diego", "CA"), ("Pasadena", "CA"), ("Brickhaven", "MA")],
            _p5, "+1", ["Inc.", "LLC", "Co.", "Corp.", "& Sons", "Group"]),
    "Canada": (4, "NA", [("Toronto", "ON"), ("Vancouver", "BC"), ("Montreal", "QC"), ("Calgary", "AB"),
                         ("Ottawa", "ON"), ("Halifax", "NS")], _ca, "+1", ["Inc.", "Ltd.", "Co.", "Group"]),
    "France": (9, "EMEA", [("Paris", None), ("Lyon", None), ("Nantes", None), ("Marseille", None),
                           ("Toulouse", None), ("Strasbourg", None), ("Lille", None), ("Bordeaux", None),
                           ("Reims", None), ("Versailles", None)], _p5, "+33", ["SA", "SARL", "et Fils", "Cie"]),
    "Germany": (7, "EMEA", [("Berlin", None), ("Munich", None), ("Frankfurt", None), ("Hamburg", None),
                            ("Cologne", None), ("Stuttgart", None), ("Dusseldorf", None), ("Mannheim", None)],
                _p5, "+49", ["GmbH", "AG", "& Co. KG"]),
    "Spain": (6, "EMEA", [("Madrid", None), ("Barcelona", None), ("Valencia", None), ("Seville", None),
                          ("Bilbao", None)], _p5, "+34", ["S.L.", "S.A.", "y Hijos"]),
    "UK": (7, "EMEA", [("London", None), ("Manchester", None), ("Liverpool", None), ("Birmingham", None),
                       ("Glasgow", None), ("Edinburgh", None)], _uk, "+44", ["Ltd", "PLC", "& Co."]),
    "Italy": (5, "EMEA", [("Milan", None), ("Rome", None), ("Turin", None), ("Bologna", None), ("Naples", None)],
              _p5, "+39", ["S.p.A.", "S.r.l.", "& Figli"]),
    "Netherlands": (2, "EMEA", [("Amsterdam", None), ("Rotterdam", None), ("Utrecht", None)], _p4, "+31", ["B.V.", "N.V."]),
    "Belgium": (2, "EMEA", [("Brussels", None), ("Antwerp", None), ("Ghent", None)], _p4, "+32", ["N.V.", "S.A."]),
    "Switzerland": (2, "EMEA", [("Zurich", None), ("Geneva", None), ("Basel", None)], _p4, "+41", ["AG", "SA"]),
    "Austria": (1.5, "EMEA", [("Vienna", None), ("Salzburg", None), ("Graz", None)], _p4, "+43", ["GmbH", "AG"]),
    "Ireland": (1.5, "EMEA", [("Dublin", None), ("Cork", None), ("Galway", None)], _p4, "+353", ["Ltd", "Teoranta"]),
    "Norway": (2, "EMEA", [("Oslo", None), ("Bergen", None), ("Stavanger", None)], _p4, "+47", ["AS", "ASA"]),
    "Sweden": (2, "EMEA", [("Stockholm", None), ("Gothenburg", None), ("Malmo", None)], _p5, "+46", ["AB", "HB"]),
    "Denmark": (2, "EMEA", [("Copenhagen", None), ("Aarhus", None), ("Odense", None)], _p4, "+45", ["A/S", "ApS"]),
    "Finland": (1.5, "EMEA", [("Helsinki", None), ("Espoo", None), ("Tampere", None)], _p5, "+358", ["Oy", "Oyj"]),
    "Australia": (5, "APAC", [("Sydney", "NSW"), ("Melbourne", "VIC"), ("Brisbane", "QLD"), ("Perth", "WA"),
                              ("Adelaide", "SA")], _p4, "+61", ["Pty Ltd", "Pty", "& Co."]),
    "New Zealand": (1.5, "APAC", [("Auckland", None), ("Wellington", None), ("Christchurch", None)], _p4, "+64", ["Ltd", "& Co."]),
    "Singapore": (2.5, "APAC", [("Singapore", None)], lambda: f"{random.randint(100000, 999999)}", "+65", ["Pte Ltd", "Pte."]),
    "Hong Kong": (1.5, "APAC", [("Hong Kong", None)], lambda: "", "+852", ["Ltd", "Co. Ltd"]),
    "Philippines": (1.5, "APAC", [("Manila", None), ("Cebu", None), ("Davao", None)], _p4, "+63", ["Inc.", "Corp."]),
    "India": (3, "APAC", [("Bengaluru", "Karnataka"), ("Mumbai", "Maharashtra"), ("Delhi", "Delhi"),
                          ("Chennai", "Tamil Nadu"), ("Hyderabad", "Telangana"), ("Pune", "Maharashtra")],
              _in, "+91", ["Pvt Ltd", "Ltd", "& Sons"]),
    "Japan": (8, "Japan", [("Tokyo", None), ("Osaka", None), ("Nagoya", None), ("Kyoto", None), ("Yokohama", None),
                           ("Sapporo", None)], _jp, "+81", ["Co., Ltd.", "K.K.", "Ltd."]),
}

# ================================================================= OFFICES
OFFICES = [
    ("1", "San Francisco", "+1 415 555 0101", "100 Market Street", "Suite 300", "CA", "USA", "94080", "NA"),
    ("2", "Boston", "+1 617 555 0102", "1550 Court Street", "Suite 102", "MA", "USA", "02107", "NA"),
    ("3", "New York", "+1 212 555 0103", "523 East 53rd Street", "Apt. 5A", "NY", "USA", "10022", "NA"),
    ("4", "Paris", "+33 1 45 55 01 04", "43 Rue de la Paix", None, None, "France", "75002", "EMEA"),
    ("5", "Tokyo", "+81 3 5555 0105", "4-1 Kioicho", "Chiyoda-Ku", "Tokyo", "Japan", "102-8578", "Japan"),
    ("6", "Sydney", "+61 2 5555 0106", "5-11 Wentworth Avenue", "Floor #2", "NSW", "Australia", "2010", "APAC"),
    ("7", "London", "+44 20 5555 0107", "25 Old Broad Street", "Level 7", None, "UK", "EC2N 1HN", "EMEA"),
    ("8", "Singapore", "+65 5555 0108", "18 Robinson Road", "Level 12", None, "Singapore", "048547", "APAC"),
    ("9", "Toronto", "+1 416 555 0109", "200 Bay Street", "Suite 1500", "ON", "Canada", "M5J 2J2", "NA"),
    ("10", "Berlin", "+49 30 5555 0110", "Friedrichstrasse 68", None, None, "Germany", "10117", "EMEA"),
]
TERR_OFFICES = {"NA": ["1", "2", "3", "9"], "EMEA": ["4", "7", "10"], "APAC": ["6", "8"], "Japan": ["5"]}
REPS_PER_TERR = {"NA": 14, "EMEA": 14, "APAC": 8, "Japan": 4}

# ================================================================ EMPLOYEES
used_names = set()


def new_person():
    while True:
        f, l = random.choice(FIRST), random.choice(LAST)
        if (f, l) not in used_names:
            used_names.add((f, l))
            return f, l


employees = []          # tuples matching the table
emp_no = 1001


def add_emp(last, first, office, reports_to, title):
    global emp_no
    n = emp_no
    emp_no += 1
    email = f"{first[0].lower()}{last.lower()}@classicmodelcars.com"
    employees.append((n, last, first, f"x{random.randint(1000, 9999)}", email, office, reports_to, title))
    return n


f, l = new_person(); president = add_emp(l, f, "1", None, "President")
f, l = new_person(); vp_sales = add_emp(l, f, "1", president, "VP Sales")
f, l = new_person(); vp_mkt = add_emp(l, f, "1", president, "VP Marketing")
managers, reps_by_terr = {}, {}
for terr in ["NA", "EMEA", "APAC", "Japan"]:
    f, l = new_person()
    managers[terr] = add_emp(l, f, TERR_OFFICES[terr][0], vp_sales, f"Sales Manager ({terr})")
for terr, n in REPS_PER_TERR.items():
    reps_by_terr[terr] = []
    for i in range(n):
        f, l = new_person()
        office = TERR_OFFICES[terr][i % len(TERR_OFFICES[terr])]
        reps_by_terr[terr].append(add_emp(l, f, office, managers[terr], "Sales Rep"))
# two brand-new reps who have not been assigned customers yet
NEW_HIRES = {reps_by_terr["NA"][-1], reps_by_terr["EMEA"][-1]}
rep_weight = {}
for terr, lst in reps_by_terr.items():
    for r in lst:
        rep_weight[r] = 0 if r in NEW_HIRES else random.uniform(0.5, 2.2)

# ================================================================ CUSTOMERS
country_names = list(COUNTRIES)
country_w = [COUNTRIES[c][0] for c in country_names]
customers, used_cust_names = [], set()
CUST_START = 101
for i in range(args.customers):
    country = wchoice(country_names, country_w)
    _, terr, cities, postal, dial, suffixes = COUNTRIES[country]
    city, state = random.choice(cities)
    while True:
        name = f"{random.choice(CUST_ADJ)} {random.choice(CUST_NOUN)} {random.choice(suffixes)}"
        if name not in used_cust_names and len(name) <= 50:
            used_cust_names.add(name)
            break
    cf, cl = random.choice(FIRST), random.choice(LAST)
    phone = f"{dial} {random.randint(20, 99)} {random.randint(100, 999)} {random.randint(1000, 9999)}"
    addr1 = f"{random.randint(1, 999)} {random.choice(STREETS)}"
    addr2 = None
    if random.random() < 0.12:
        addr2 = random.choice([f"Suite {random.randint(100, 999)}", f"Floor {random.randint(2, 30)}",
                               f"Unit {random.randint(1, 60)}"])
    if random.random() < 0.04:
        rep = None
    else:
        pool = [r for r in reps_by_terr[terr] if rep_weight[r] > 0]
        rep = wchoice(pool, [rep_weight[r] for r in pool])
    if random.random() < 0.06:
        limit = 0
    else:
        limit = round(random.triangular(5000, 250000, 45000) / 100) * 100
    customers.append((CUST_START + i, name, cl, cf, phone, addr1, addr2, city, state, postal() or None, country,
                      rep, Money(money(cents(limit)))))

# ================================================================ PRODUCT LINES
LINES = {
    "Classic Cars": "Attention car enthusiasts: display your classic muscle cars and roadsters with scale replicas "
                    "of the most iconic post-war automobiles, built with opening doors, detailed engines and "
                    "hand-finished paintwork.",
    "Motorcycles": "Our motorcycles are state of the art replicas of classic as well as contemporary motorcycle "
                   "legends such as Harley Davidson, Ducati and Vespa. Models come with stand-up kickstands, "
                   "adjustable handlebars and detailed engines.",
    "Planes": "Unique, diecast airplane and helicopter replicas suitable for collections, as well as home, office "
              "or classroom decorations. Models are fully assembled and hand-painted.",
    "Ships": "The perfect holiday or anniversary gift for executives, clients, friends and family. These ship "
             "models are made of wood and metal and come with detailed rigging and display stands.",
    "Trains": "Model trains are a rewarding hobby for enthusiasts of all ages. Our replicas feature detailed "
              "locomotives, rolling stock and accessories in a range of scales.",
    "Trucks and Buses": "The Truck and Bus models are realistic replicas of buses and specialist trucks produced "
                        "from the early 1920s to present. They feature detailed interiors and opening doors.",
    "Vintage Cars": "Our Vintage Car models realistically portray automobiles produced from the early 1900s "
                    "through the 1940s. Materials include steel, zinc and die-cast alloy, with authentic detailing.",
}
productlines = [(k, v, None, None) for k, v in LINES.items()]

# ================================================================== PRODUCTS
CARS = ["Ford Mustang", "Ford Thunderbird", "Chevrolet Corvette", "Chevrolet Bel Air", "Chevrolet Camaro",
        "Cadillac Eldorado", "Dodge Charger", "Pontiac GTO", "Plymouth Barracuda", "Jaguar E-Type",
        "Aston Martin DB5", "Mercedes-Benz 300SL", "Porsche 356", "Porsche 911", "Ferrari 250 GTO",
        "Ferrari Testarossa", "Lamborghini Miura", "Alfa Romeo Spider", "Fiat 500", "Volkswagen Beetle",
        "Mini Cooper", "Bentley Continental", "Lincoln Continental", "Buick Riviera", "Oldsmobile 442",
        "Shelby Cobra", "De Tomaso Pantera", "Maserati Ghibli", "Austin Healey 3000", "Studebaker Avanti",
        "Citroen DS", "Datsun 240Z", "Toyota 2000GT", "Nissan Skyline", "Triumph TR6", "Lotus Elan",
        "AC Ace", "Jensen Interceptor", "Chrysler 300", "Ford Falcon", "Ford Fairlane", "Mercury Cougar"]
VINTAGE = ["Ford Model T", "Ford Model A", "Chevrolet Superior", "Cadillac V16", "Rolls-Royce Phantom",
           "Bugatti Type 57", "Duesenberg Model J", "Packard Twin Six", "Stutz Bearcat", "Mercer Raceabout",
           "Hispano-Suiza H6", "Auburn Speedster", "Cord 810", "Pierce-Arrow Series 80", "Lincoln Model K",
           "Chrysler Airflow", "Daimler DE36", "Bentley 4.5 Litre", "Delahaye 135", "Alfa Romeo 8C",
           "Mercedes-Benz SSK", "Bugatti Royale", "Peugeot Type 3", "Renault AX", "Buick Model 10", "Oldsmobile Curved Dash"]
BODY = ["", "", "", " Coupe", " Roadster", " Convertible", " Sedan", " Fastback", " Tourer"]
MOTO_B = ["Harley Davidson", "Ducati", "Triumph", "Indian", "Honda", "Yamaha", "Kawasaki", "BMW", "Vespa",
          "Royal Enfield", "Suzuki", "Norton", "Moto Guzzi", "Aprilia", "Lambretta"]
MOTO_M = ["Ultimate Chopper", "Bonneville", "Scout", "Interceptor", "Sportster", "Monster", "Cruiser", "Gold Wing",
          "Super Cub", "Café Racer", "Softail", "Road King", "Panigale", "Commando", "Thunderbird", "Bullet"]
PLANES = ["P-51 Mustang", "Spitfire Mk IX", "Boeing 747", "Concorde", "Cessna 172 Skyhawk", "F-16 Fighting Falcon",
          "Douglas DC-3", "Lockheed Constellation", "Piper Cub", "Sopwith Camel", "Fokker Dr.I", "Bell UH-1 Huey",
          "Boeing 787 Dreamliner", "Airbus A380", "B-17 Flying Fortress", "Messerschmitt Bf 109", "Zero Fighter",
          "Lancaster Bomber", "Hawker Hurricane", "Supermarine Seafire", "Sikorsky S-58", "Lockheed SR-71",
          "Boeing 737", "Learjet 23", "Beechcraft Bonanza", "Vought Corsair", "Grumman Hellcat", "Avro Vulcan",
          "de Havilland Mosquito", "Curtiss Jenny", "Wright Flyer", "Airbus A320", "Comet 4"]
SHIPS = ["HMS Victory", "USS Constitution", "RMS Queen Mary", "RMS Titanic", "Bismarck", "Santa Maria", "Mayflower",
         "Cutty Sark", "Yamato", "Nautilus Submarine", "Endeavour", "Golden Hind", "Viking Longship", "Chinese Junk",
         "Schooner Bluenose", "HMS Bounty", "SS Great Britain", "Kon-Tiki", "Clipper Thermopylae", "USS Missouri",
         "Sea Cloud", "Steam Paddle Boat", "Tall Ship Gorch Fock", "Dhow of Zanzibar"]
TRAINS = ["Steam Locomotive 4-6-2", "Diesel Freight GP38", "Orient Express Coach", "Bullet Train Series 500",
          "Union Pacific Big Boy", "Flying Scotsman", "Stephenson's Rocket", "Pullman Sleeper Car", "Red Caboose",
          "Maglev Express", "Santa Fe Super Chief", "Mallard A4", "Shinkansen N700", "TGV Duplex", "ICE 3",
          "Royal Scot", "Heritage Steam Tank", "Mining Ore Wagon"]
TRUCKS = ["Mack Fire Engine", "Greyhound Bus", "London Double-Decker Bus", "Route 66 Diner Truck", "Ice Cream Truck",
          "Peterbilt Tanker", "Kenworth Logging Truck", "Volkswagen Type 2 Bus", "Yellow School Bus", "Tow Truck",
          "Milk Delivery Van", "Dump Truck", "Postal Delivery Van", "Airport Shuttle Bus", "Cement Mixer",
          "Flatbed Lorry", "Food Truck", "Ambulance", "Delivery Panel Van", "Refrigerated Semi", "Trolley Bus"]
EDITIONS = ["", "", "", " - Silver Edition", " - Collector Series", " - Limited Run", " - Desert Camo", " - Racing Livery",
            " - Anniversary Edition", " - Premium Finish", " - Museum Grade"]
VENDORS = ["Min Lin Diecast", "Classic Metal Creations", "Highway 66 Mini Classics", "Red Start Diecast",
           "Motor City Art Classics", "Welly Diecast Productions", "Autoart Studio Design", "Unimax Art Galleries",
           "Studio M Art Models", "Exoto Designs", "Gearbox Collectibles", "Carousel DieCast Legends",
           "Second Gear Diecast", "Corgi Classics", "Iron Horse Miniatures", "Blue Harbour Models",
           "Aero Craft Replicas", "Silverline Diecast", "Heritage Mint", "Precision Scale Works"]
SCALES = {"1:10": 4, "1:12": 8, "1:18": 30, "1:24": 28, "1:32": 8, "1:50": 10, "1:72": 6, "1:700": 6}
FEATURES = ["opening doors", "detailed engine", "hand-painted finish", "working steering", "rubber tyres",
            "chrome trim", "removable roof", "authentic interior", "die-cast metal body", "rotating wheels",
            "limited production run", "display stand included", "true-to-scale badge details"]

LINE_PLAN = [  # (line, share, names, year range, buy price range)
    ("Classic Cars", 0.22, CARS, (1948, 1999), (22, 100)),
    ("Vintage Cars", 0.18, VINTAGE, (1903, 1948), (16, 88)),
    ("Motorcycles", 0.12, None, (1936, 2004), (26, 96)),
    ("Planes", 0.14, PLANES, None, (26, 82)),
    ("Ships", 0.10, SHIPS, None, (20, 76)),
    ("Trains", 0.08, TRAINS, None, (20, 66)),
    ("Trucks and Buses", 0.16, TRUCKS, (1926, 1995), (26, 96)),
]
products, used_pn, used_codes = [], set(), set()
for line, share, names, yrs, (lo, hi) in LINE_PLAN:
    target = max(3, round(args.products * share))
    made = 0
    while made < target:
        if line == "Motorcycles":
            base = f"{random.randint(*yrs)} {random.choice(MOTO_B)} {random.choice(MOTO_M)}"
        elif line in ("Classic Cars", "Vintage Cars", "Trucks and Buses"):
            base = f"{random.randint(*yrs)} {random.choice(names)}"
            if line != "Trucks and Buses":
                base += random.choice(BODY)
        else:
            base = random.choice(names)
        name = base + random.choice(EDITIONS)
        if name in used_pn or len(name) > 70:
            continue
        used_pn.add(name)
        scale = wchoice(list(SCALES), list(SCALES.values()))
        if line in ("Planes", "Ships", "Trains") and scale in ("1:10", "1:12"):
            scale = random.choice(["1:32", "1:50", "1:72", "1:700"] if line != "Trains" else ["1:32", "1:50"])
        while True:
            code = f"S{scale.split(':')[1]}_{random.randint(1000, 4999)}"
            if code not in used_codes:
                used_codes.add(code)
                break
        vendor = random.choice(VENDORS)
        r = random.random()
        stock = random.randint(0, 99) if r < 0.05 else random.randint(100, 999) if r < 0.25 else random.randint(1000, 9500)
        buy = cents(random.uniform(lo, hi))
        msrp = cents(buy / 100 * random.uniform(1.45, 2.30))
        f1, f2 = random.sample(FEATURES, 2)
        desc = (f"Detailed {scale} scale replica of the {name} from {vendor}. Features {f1} and {f2}. "
                f"Every piece is inspected by hand before shipping.")
        products.append((code, name, line, scale, vendor, desc, stock, Money(money(buy)), Money(money(msrp))))
        made += 1
random.shuffle(products)
prod_codes = [p[0] for p in products]
prod_msrp = {p[0]: float(p[8]) for p in products}
prod_buy = {p[0]: float(p[7]) for p in products}
# popularity weights (about 5 % of the catalogue is never ordered)
pop_w = [0 if random.random() < 0.05 else random.lognormvariate(0, 0.8) for _ in prod_codes]
pop_cum = list(accumulate(pop_w))

# ============================================================== ORDERS & DETAILS
cust_ids = [c[0] for c in customers]
cust_w = [0 if random.random() < 0.10 else random.lognormvariate(0, 0.7) for _ in cust_ids]  # ~10 % never order
cust_cum = list(accumulate(cust_w))
month_w = [0.8, 0.8, 0.9, 0.9, 1.0, 1.0, 1.0, 1.05, 1.2, 1.4, 1.6, 1.3]
span = (LAST_ORDER - FIRST_ORDER).days


def random_order_date():
    while True:
        d = FIRST_ORDER + dt.timedelta(days=random.randint(0, span))
        growth = 0.75 + 0.12 * (d.year - 2022)
        if random.random() < month_w[d.month - 1] / 1.6 * growth / 1.2:
            return d


def pick(cum, items):
    return items[bisect_left(cum, random.random() * cum[-1])]


orders, details, order_total = [], [], {}
ORDER_START = 10100
for i in range(args.orders):
    onum = ORDER_START + i
    odate = random_order_date()
    cust = pick(cust_cum, cust_ids)
    required = odate + dt.timedelta(days=random.randint(5, 12))
    ship_days = random.randint(1, 7) if random.random() > 0.08 else random.randint(8, 14)
    shipped = odate + dt.timedelta(days=ship_days)
    comments = None
    recent = odate >= TODAY - dt.timedelta(days=16)          # recent orders are mostly still being processed
    if shipped > TODAY or (recent and random.random() < 0.85):
        status, shipped = "In Process", None
    else:
        r = random.random()
        if r < 0.020:
            status, shipped = "Cancelled", None
            comments = random.choice(["Customer cancelled due to budget cuts.", "Cancelled at customer request.",
                                      "Order cancelled - duplicate submission."])
        elif r < 0.033:
            status, shipped = "On Hold", None
            comments = random.choice(["Awaiting credit approval.", "On hold pending customer confirmation."])
        elif r < 0.045:
            status = "Disputed"
            comments = random.choice(["Customer claims order was not received.", "Disputed - quantity mismatch."])
        elif r < 0.070:
            status = "Resolved"
            comments = random.choice(["Dispute resolved in customer's favour.", "Issue resolved after replacement."])
        else:
            status = "Shipped"
            if random.random() < 0.04:
                comments = random.choice(["Customer requested expedited delivery.", "Fragile - handle with care.",
                                          "Gift wrap requested."])
    orders.append((onum, odate, required, shipped, status, comments, cust))
    k = random.choices(range(1, 12), weights=[3, 8, 12, 14, 14, 12, 10, 8, 5, 3, 1])[0]
    chosen = []
    while len(chosen) < k:
        p = pick(pop_cum, prod_codes)
        if p not in chosen:
            chosen.append(p)
    total = 0
    for line_no, pc in enumerate(chosen, start=1):
        qty = random.randint(10, 60) if random.random() > 0.05 else random.randint(61, 100)
        price = max(prod_buy[pc] * 1.05, prod_msrp[pc] * random.uniform(0.62, 1.0))
        pc_c = cents(price)
        details.append((onum, pc, qty, Money(money(pc_c)), line_no))
        total += qty * pc_c
    order_total[onum] = total

# ================================================================== PAYMENTS
payments, used_checks = [], set()
for (onum, odate, req, shipped, status, _c, cust) in orders:
    if status not in ("Shipped", "Resolved", "Disputed") or shipped is None:
        continue
    if random.random() > 0.90:          # ~10 % of shipped orders are still unpaid
        continue
    pdate = shipped + dt.timedelta(days=random.randint(7, 60))
    if pdate > TODAY:
        continue
    amount = order_total[onum]
    if random.random() < 0.08:          # occasional part payment
        amount = int(amount * random.uniform(0.4, 0.9))
    while True:
        chk = f"{random.choice('ABCDEFGHJKLMNPQRSTUVWXYZ')}{random.choice('ABCDEFGHJKLMNPQRSTUVWXYZ')}{random.randint(10000, 999999)}"
        if chk not in used_checks:
            used_checks.add(chk)
            break
    payments.append((cust, chk, pdate, Money(money(amount))))
payments.sort(key=lambda r: (r[2], r[0]))

# ===================================================================== OUTPUT
TABLES = [
    ("productlines", ["productLine", "textDescription", "htmlDescription", "image"], productlines),
    ("products", ["productCode", "productName", "productLine", "productScale", "productVendor", "productDescription",
                  "quantityInStock", "buyPrice", "MSRP"], products),
    ("offices", ["officeCode", "city", "phone", "addressLine1", "addressLine2", "state", "country", "postalCode",
                 "territory"], OFFICES),
    ("employees", ["employeeNumber", "lastName", "firstName", "extension", "email", "officeCode", "reportsTo",
                   "jobTitle"], employees),
    ("customers", ["customerNumber", "customerName", "contactLastName", "contactFirstName", "phone", "addressLine1",
                   "addressLine2", "city", "state", "postalCode", "country", "salesRepEmployeeNumber",
                   "creditLimit"], customers),
    ("orders", ["orderNumber", "orderDate", "requiredDate", "shippedDate", "status", "comments", "customerNumber"],
     orders),
    ("orderdetails", ["orderNumber", "productCode", "quantityOrdered", "priceEach", "orderLineNumber"], details),
    ("payments", ["customerNumber", "checkNumber", "paymentDate", "amount"], payments),
]

os.makedirs(os.path.join(ROOT, "sql"), exist_ok=True)
os.makedirs(os.path.join(ROOT, "data"), exist_ok=True)
os.makedirs(os.path.join(ROOT, "sqlite"), exist_ok=True)

# ---- CSV
for name, cols, rows in TABLES:
    with open(os.path.join(ROOT, "data", f"{name}.csv"), "w", newline="", encoding="utf-8") as fh:
        w = csv.writer(fh)
        w.writerow(cols)
        for r in rows:
            w.writerow(["" if v is None else (v.isoformat() if isinstance(v, dt.date) else str(v)) for v in r])

# ---- MySQL inserts
BATCH = 500
with open(os.path.join(ROOT, "sql", "02_data.sql"), "w", encoding="utf-8") as fh:
    fh.write("-- =====================================================================\n"
             "--  ClassicModels Query Challenge  |  02_data.sql  (MySQL 8 / MariaDB)\n"
             f"--  Synthetic dataset, seed={args.seed}.  Load AFTER 01_schema.sql.\n"
             "--  Row counts: " + ", ".join(f"{n}={len(r):,}" for n, _c, r in TABLES) + "\n"
             "-- =====================================================================\n\n"
             "USE classicmodels;\nSET NAMES utf8mb4;\nSET FOREIGN_KEY_CHECKS = 0;\nSET UNIQUE_CHECKS = 0;\n"
             "SET AUTOCOMMIT = 0;\n\n")
    for name, cols, rows in TABLES:
        fh.write(f"-- {name}: {len(rows):,} rows\n")
        for i in range(0, len(rows), BATCH):
            chunk = rows[i:i + BATCH]
            fh.write(f"INSERT INTO {name} ({', '.join(cols)}) VALUES\n")
            fh.write(",\n".join(sql_row(r) for r in chunk))
            fh.write(";\n")
        fh.write("COMMIT;\n\n")
    fh.write("SET UNIQUE_CHECKS = 1;\nSET FOREIGN_KEY_CHECKS = 1;\nSET AUTOCOMMIT = 1;\n")

# ---- SQLite
SQLITE_DDL = """
PRAGMA foreign_keys = OFF;
CREATE TABLE productlines (productLine TEXT PRIMARY KEY, textDescription TEXT, htmlDescription TEXT, image BLOB);
CREATE TABLE products (productCode TEXT PRIMARY KEY, productName TEXT NOT NULL, productLine TEXT NOT NULL REFERENCES productlines(productLine),
  productScale TEXT NOT NULL, productVendor TEXT NOT NULL, productDescription TEXT NOT NULL, quantityInStock INTEGER NOT NULL,
  buyPrice REAL NOT NULL, MSRP REAL NOT NULL);
CREATE TABLE offices (officeCode TEXT PRIMARY KEY, city TEXT NOT NULL, phone TEXT NOT NULL, addressLine1 TEXT NOT NULL,
  addressLine2 TEXT, state TEXT, country TEXT NOT NULL, postalCode TEXT NOT NULL, territory TEXT NOT NULL);
CREATE TABLE employees (employeeNumber INTEGER PRIMARY KEY, lastName TEXT NOT NULL, firstName TEXT NOT NULL, extension TEXT NOT NULL,
  email TEXT NOT NULL, officeCode TEXT NOT NULL REFERENCES offices(officeCode), reportsTo INTEGER REFERENCES employees(employeeNumber),
  jobTitle TEXT NOT NULL);
CREATE TABLE customers (customerNumber INTEGER PRIMARY KEY, customerName TEXT NOT NULL, contactLastName TEXT NOT NULL,
  contactFirstName TEXT NOT NULL, phone TEXT NOT NULL, addressLine1 TEXT NOT NULL, addressLine2 TEXT, city TEXT NOT NULL, state TEXT,
  postalCode TEXT, country TEXT NOT NULL, salesRepEmployeeNumber INTEGER REFERENCES employees(employeeNumber), creditLimit REAL);
CREATE TABLE orders (orderNumber INTEGER PRIMARY KEY, orderDate TEXT NOT NULL, requiredDate TEXT NOT NULL, shippedDate TEXT,
  status TEXT NOT NULL, comments TEXT, customerNumber INTEGER NOT NULL REFERENCES customers(customerNumber));
CREATE TABLE orderdetails (orderNumber INTEGER NOT NULL REFERENCES orders(orderNumber), productCode TEXT NOT NULL REFERENCES products(productCode),
  quantityOrdered INTEGER NOT NULL, priceEach REAL NOT NULL, orderLineNumber INTEGER NOT NULL, PRIMARY KEY (orderNumber, productCode));
CREATE TABLE payments (customerNumber INTEGER NOT NULL REFERENCES customers(customerNumber), checkNumber TEXT NOT NULL,
  paymentDate TEXT NOT NULL, amount REAL NOT NULL, PRIMARY KEY (customerNumber, checkNumber));
CREATE INDEX idx_products_line ON products(productLine);
CREATE INDEX idx_customers_country ON customers(country);
CREATE INDEX idx_customers_rep ON customers(salesRepEmployeeNumber);
CREATE INDEX idx_orders_customer ON orders(customerNumber);
CREATE INDEX idx_orders_date ON orders(orderDate);
CREATE INDEX idx_od_product ON orderdetails(productCode);
CREATE INDEX idx_pay_date ON payments(paymentDate);
"""
# MySQL's default collations are case-insensitive; mirror that so ORDER BY / = behave the same in SQLite
SQLITE_DDL = SQLITE_DDL.replace(" TEXT", " TEXT COLLATE NOCASE")
dbpath = os.path.join(ROOT, "sqlite", "classicmodels.db")
if os.path.exists(dbpath):
    os.remove(dbpath)
con = sqlite3.connect(dbpath)
con.executescript(SQLITE_DDL)
for name, cols, rows in TABLES:
    conv = []
    for r in rows:
        conv.append(tuple(float(v) if isinstance(v, Money) else (v.isoformat() if isinstance(v, dt.date) else v)
                          for v in r))
    con.executemany(f"INSERT INTO {name} ({','.join(cols)}) VALUES ({','.join('?' * len(cols))})", conv)
con.commit()
con.execute("VACUUM")
con.close()

print("Generated dataset (seed=%d):" % args.seed)
for name, _c, rows in TABLES:
    print(f"  {name:<13}{len(rows):>9,} rows")
print(f"  {'TOTAL':<13}{sum(len(r) for _n, _c, r in TABLES):>9,} rows")
