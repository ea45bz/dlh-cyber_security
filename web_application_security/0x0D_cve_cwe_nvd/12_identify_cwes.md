## 1. Identified CWE(s)

| CWE ID                                                                                           | Description                                                                                                                        |
| ------------------------------------------------------------------------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------- |
| **CWE‑89: Improper Neutralization of Special Elements used in an SQL Statement (SQL Injection)** | The code concatenates unsanitized user input (`username`) directly into the SQL query, enabling attackers to inject arbitrary SQL. |

> _Only one concrete weakness is present; the rest of the snippet follows normal patterns._

---

## 2. Security Implications & Attack Scenarios

| CWE‑89            | What an attacker can do                                                                                                                                                                                                                                                                                                                |
| ----------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **SQL Injection** | - **Read or modify data**: `username='admin' OR '1'='1'` returns all rows.<br>- **Privilege escalation**: inject sub‑queries to insert malicious records, create new admin users, or drop tables.<br>- **Denial of Service (DoS)**: use large payloads (`SELECT * FROM users WHERE username='' UNION SELECT ...`) to overwhelm the DB. |

Because the code never sanitizes or parameterizes input, any user-provided string will be executed exactly as part of the SQL command. This flaw can lead to data theft, corruption, and full compromise of the database.

---

## 3. Mitigation Recommendation

**Use parameterized queries**

```python
query = "SELECT * FROM users WHERE username=?"
cursor.execute(query, (username,))
```

The SQLite driver escapes the value automatically; no attacker‑controlled string can alter the query structure.

### Quick Code Fix

```python
import sqlite3

def get_user(username):
    conn = sqlite3.connect('users.db')
    try:
        cursor = conn.cursor()
        # Parameterized query – no string concatenation!
        cursor.execute("SELECT * FROM users WHERE username=?", (username,))
        return cursor.fetchone()
    finally:
        conn.close()      # Ensures connection is closed even on error
```

This minimal change eliminates CWE‑89 by preventing user input from influencing the SQL command’s structure, thereby safeguarding the database against injection attacks.
