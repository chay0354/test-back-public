from datetime import datetime
from flask import Flask, request, jsonify
from flask_cors import CORS
import pyodbc
import json
import urllib.request
import urllib.error
import logging

# ─── Initialize Flask ─────────────────────────
app = Flask(__name__)
CORS(app, origins=[
    "http://localhost:3000",
    "https://main.d1kjnkw0alpy3y.amplifyapp.com"
])
application = app

# ─── Configuration ───────────────────────────────────────────────────────────
OPENAI_API_KEY = "*****"##deleted here but visable in prodaction, because open ai blocks api keys that are in public repositiories
RDS_CONN_STR = (
    "DRIVER={ODBC Driver 17 for SQL Server};"
    "SERVER=database-1.c9mk4maoajh5.eu-north-1.rds.amazonaws.com;"
    "DATABASE=AdventureWorks2019;"
    "UID=admin;PWD=chay0386"
)

# ─── Logging ────────────────────────────────────────────────────────────────
logging.basicConfig(level=logging.INFO)

def get_connection():
    return pyodbc.connect(RDS_CONN_STR)

# ─── Generate SQL via OpenAI API ─────────────────────────────────────────────
def generate_sql(prompt):
    system_prompt = (
        "You are a T-SQL expert. Generate only valid Microsoft SQL Server SELECT queries.\n"
        "Use uppercase SQL keywords and [square brackets] for all identifiers.\n"
        "NEVER use the keyword TO unless it's part of BETWEEN ... AND ...\n"
        "Avoid SELECT INTO, INSERT, UPDATE, DELETE, CREATE, or markdown formatting.\n"
        "Use JOINs with ON clauses when necessary. Start CTEs with a semicolon.\n"
        "Only return the clean T-SQL query—no explanations or comments."
    )
    payload = {
        "model": "gpt-4o",
        "messages": [
            {"role": "system", "content": system_prompt},
            {"role": "user",   "content": prompt}
        ],
        "temperature": 0
    }
    data = json.dumps(payload).encode("utf-8")
    req = urllib.request.Request(
        "https://api.openai.com/v1/chat/completions",
        data=data,
        headers={
            "Authorization": f"Bearer {OPENAI_API_KEY}",
            "Content-Type": "application/json"
        },
        method="POST"
    )
    try:
        with urllib.request.urlopen(req, timeout=30) as resp:
            result = json.loads(resp.read().decode("utf-8"))
            sql = result["choices"][0]["message"]["content"].strip()
            # Basic guard against invalid TO usage
            upper = sql.upper()
            if " TO " in upper and "BETWEEN" not in upper:
                raise Exception("Invalid use of 'TO' keyword detected in SQL.")
            return sql
    except urllib.error.HTTPError as e:
        raise Exception(f"OpenAI API error {e.code}: {e.read().decode()}")
    except Exception as e:
        raise Exception(f"Failed to generate SQL: {e}")

# ─── Introspect Schema & FK Relationships ───────────────────────────────────
def introspect_schema():
    conn = get_connection()
    cur = conn.cursor()

    cur.execute("""
        SELECT TABLE_NAME
        FROM INFORMATION_SCHEMA.TABLES
        WHERE TABLE_TYPE='BASE TABLE' AND TABLE_SCHEMA='dbo'
    """)
    tables = [r[0] for r in cur.fetchall()]
    schema_lines = []
    for table in tables:
        c = conn.cursor()
        c.execute("""
            SELECT COLUMN_NAME
            FROM INFORMATION_SCHEMA.COLUMNS
            WHERE TABLE_SCHEMA='dbo' AND TABLE_NAME=?
            ORDER BY ORDINAL_POSITION
        """, table)
        cols = [col[0] for col in c.fetchall()]
        schema_lines.append(f"[{table}](" + ",".join(f"[{col}]" for col in cols) + ")")

    cur.execute("""
        SELECT
            FK.TABLE_NAME AS FK_TABLE,
            CU.COLUMN_NAME AS FK_COLUMN,
            PK.TABLE_NAME AS PK_TABLE,
            PT.COLUMN_NAME AS PK_COLUMN
        FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS RC
        JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS FK
            ON RC.CONSTRAINT_NAME = FK.CONSTRAINT_NAME
        JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS PK
            ON RC.UNIQUE_CONSTRAINT_NAME = PK.CONSTRAINT_NAME
        JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE CU
            ON CU.CONSTRAINT_NAME = FK.CONSTRAINT_NAME
        JOIN (
            SELECT TC.TABLE_NAME, KU.COLUMN_NAME, TC.CONSTRAINT_NAME
            FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS TC
            JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE KU
                ON TC.CONSTRAINT_NAME = KU.CONSTRAINT_NAME
            WHERE TC.CONSTRAINT_TYPE='PRIMARY KEY'
        ) PT ON PT.CONSTRAINT_NAME = PK.CONSTRAINT_NAME
    """)
    rels = [f"{r.FK_TABLE}.{r.FK_COLUMN} = {r.PK_TABLE}.{r.PK_COLUMN}" for r in cur.fetchall()]

    conn.close()
    return "; ".join(schema_lines), "; ".join(rels)

# ─── /query ─────────────────────────────────────────────────────────────────
@app.route("/query", methods=["POST"])
def query():
    try:
        data = request.get_json(force=True)
        question = data.get("question", "").strip()
        if not question:
            return jsonify({"error": "Missing 'question'"}), 400

        schema_text, rel_text = introspect_schema()

        now = datetime.now()
        prompt = (
            f"Today's date is {now:%Y-%m-%d}. The current year is {now.year} "
            f"and the current month is {now.month}.\n\n"
            f"Database schema:\n{schema_text}\n\n"
            f"Relationships:\n{rel_text}\n\n"
            f"Convert the following natural-language question into valid T-SQL:\n"
            f"Question: {question}\n"
            "SQL:"
        )

        raw_sql = generate_sql(prompt)
        sql = raw_sql.replace("```sql", "").replace("```", "").strip()
        if sql.upper().startswith("WITH "):
            sql = ";" + sql

        logging.info(f"[SQL] {sql}")

        conn = get_connection()
        cur = conn.cursor()
        cur.execute(sql)
        cols = [d[0] for d in (cur.description or [])]
        rows = [dict(zip(cols, row)) for row in cur.fetchall()]
        conn.close()

        return jsonify({"question": question, "sql": sql, "results": rows}), 200

    except Exception as e:
        logging.error(f"[ERROR] {e}")
        return jsonify({"error": str(e)}), 500

# ─── /tables ─────────────────────────────────────────────────────────────────
@app.route("/tables", methods=["GET"])
def list_tables():
    conn = get_connection()
    cur = conn.cursor()
    cur.execute("""
        SELECT TABLE_NAME
        FROM INFORMATION_SCHEMA.TABLES
        WHERE TABLE_TYPE='BASE TABLE' AND TABLE_SCHEMA='dbo'
    """)
    tables = [row[0] for row in cur.fetchall()]
    conn.close()
    return jsonify({"tables": tables}), 200

# ─── /tables/<table> ─────────────────────────────────────────────────────────
@app.route("/tables/<table_name>", methods=["GET"])
def get_table(table_name):
    conn = get_connection()
    cur = conn.cursor()
    cur.execute(f"SELECT * FROM dbo.[{table_name}]")
    cols = [d[0] for d in cur.description]
    rows = [dict(zip(cols, row)) for row in cur.fetchall()]
    conn.close()
    return jsonify({"table": table_name, "columns": cols, "rows": rows}), 200

# ─── Run App ────────────────────────────────────────────────────────────────
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
