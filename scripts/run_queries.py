#!/usr/bin/env python3
"""
ClassicModels Query Challenge - query runner
============================================
Runs every query in sql/03_queries.sql against the bundled SQLite database
(no MySQL needed) and prints the results / writes a Markdown report.

MySQL date helpers YEAR() and MONTH() are registered as SQLite functions so
the very same SQL text runs on both engines.

Examples (from the project root):
    python3 scripts/run_queries.py                    # run everything, print a summary
    python3 scripts/run_queries.py --only A01,C05     # run selected questions and show rows
    python3 scripts/run_queries.py --section C        # run a whole section
    python3 scripts/run_queries.py --report results/04_query_results.md
"""
import argparse
import os
import re
import sqlite3
import sys
import textwrap
from decimal import Decimal, ROUND_HALF_UP

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
HEADER = re.compile(r"^--\s*\[([A-Z]\d{2})\]\s*(.+?)\s*$")


def parse_queries(path):
    """Return a list of dicts: id, title, question, skills, sql."""
    queries, cur = [], None
    with open(path, encoding="utf-8") as fh:
        for raw in fh:
            line = raw.rstrip("\n")
            m = HEADER.match(line)
            if m:
                cur = {"id": m.group(1), "title": m.group(2), "question": "", "skills": "", "sql": []}
                queries.append(cur)
                continue
            if cur is None:
                continue
            s = line.strip()
            if s.startswith("-- Question"):
                cur["question"] = s.split(":", 1)[1].strip()
            elif s.startswith("-- Skills"):
                cur["skills"] = s.split(":", 1)[1].strip()
            elif s.startswith("--") or not s:
                if cur["sql"] and cur.get("done"):
                    cur = None
                continue
            else:
                if cur.get("done"):          # statement already finished -> stray line (e.g. USE ...)
                    cur = None
                    continue
                cur["sql"].append(line)
                if s.endswith(";"):
                    cur["done"] = True
    for q in queries:
        q["sql"] = "\n".join(q["sql"]).strip()
    return queries


def _round_half_up(x, digits=0):
    """MySQL-style ROUND on DECIMAL data (round half up), instead of SQLite's binary-float rounding."""
    if x is None:
        return None
    q = Decimal(1).scaleb(-int(digits))
    return float(Decimal(repr(float(x))).quantize(q, rounding=ROUND_HALF_UP))


def connect(db_path):
    con = sqlite3.connect(db_path)
    # MySQL functions that SQLite does not have (or rounds differently)
    con.create_function("YEAR", 1, lambda d: int(d[:4]) if d else None)
    con.create_function("MONTH", 1, lambda d: int(d[5:7]) if d else None)
    con.create_function("ROUND", 1, lambda x: _round_half_up(x, 0))
    con.create_function("ROUND", 2, _round_half_up)
    return con


def fmt(v):
    if v is None:
        return "NULL"
    if isinstance(v, float):
        return f"{v:,.2f}"
    return str(v)


def md_table(cols, rows):
    out = ["| " + " | ".join(cols) + " |", "|" + "|".join("---" for _ in cols) + "|"]
    for r in rows:
        out.append("| " + " | ".join(fmt(v).replace("|", "\\|") for v in r) + " |")
    return "\n".join(out)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--db", default=os.path.join(ROOT, "sqlite", "classicmodels.db"))
    ap.add_argument("--queries", default=os.path.join(ROOT, "sql", "03_queries.sql"))
    ap.add_argument("--only", help="comma separated question ids, e.g. A01,B05")
    ap.add_argument("--section", help="A, B, C or D")
    ap.add_argument("--rows", type=int, default=10, help="max rows to show per query")
    ap.add_argument("--report", help="write a Markdown report to this path")
    args = ap.parse_args()

    queries = parse_queries(args.queries)
    if args.only:
        wanted = {x.strip().upper() for x in args.only.split(",")}
        queries = [q for q in queries if q["id"] in wanted]
    if args.section:
        queries = [q for q in queries if q["id"].startswith(args.section.upper())]
    verbose = bool(args.only)

    con = connect(args.db)
    sections = {"A": "Customer Analysis", "B": "Product Analysis", "C": "Payment Analysis",
                "D": "Bonus - JOINs and business insights"}
    report, failures, last_sec = [], 0, None
    if args.report:
        report.append("# ClassicModels Query Challenge - Query Results\n")
        report.append("Output of every query in `sql/03_queries.sql`, executed on the bundled dataset "
                      "(`sqlite/classicmodels.db`). Each table shows at most the first "
                      f"{args.rows} rows; the row count is the full size of the result.\n")

    for q in queries:
        try:
            cur = con.execute(q["sql"])
            cols = [d[0] for d in cur.description]
            rows = cur.fetchall()
            status = f"{len(rows):>4} rows"
        except Exception as exc:                               # noqa: BLE001
            cols, rows, status, failures = [], [], f"ERROR: {exc}", failures + 1
        print(f"[{q['id']}] {q['title']:<45} {status}")
        if verbose:
            print("     " + textwrap.fill(q["question"], 100, subsequent_indent="     "))
            print("     " + " | ".join(cols))
            for r in rows[:args.rows]:
                print("     " + " | ".join(fmt(v) for v in r))
            print()
        if args.report:
            if q["id"][0] != last_sec:
                last_sec = q["id"][0]
                report.append(f"\n---\n\n## Section {last_sec} - {sections.get(last_sec, '')}\n")
            report.append(f"### {q['id']} - {q['title']}\n")
            report.append(f"**Question:** {q['question']}  ")
            report.append(f"**Skills:** {q['skills']}\n")
            report.append("```sql\n" + q["sql"] + "\n```\n")
            if cols:
                shown = rows[:args.rows]
                report.append(md_table(cols, shown))
                more = f" (showing first {args.rows})" if len(rows) > args.rows else ""
                report.append(f"\n*{len(rows):,} row(s) returned{more}.*\n")
            else:
                report.append(f"**{status}**\n")

    if args.report:
        os.makedirs(os.path.dirname(os.path.abspath(args.report)), exist_ok=True)
        with open(args.report, "w", encoding="utf-8") as fh:
            fh.write("\n".join(report) + "\n")
        print(f"\nReport written to {args.report}")
    print(f"\n{len(queries)} queries run, {failures} failed.")
    sys.exit(1 if failures else 0)


if __name__ == "__main__":
    main()
