# Database rebuild and verification

This folder contains the SQL and helper scripts used for Assignment 2.

Files:
- `rebuild.sql` — creates the `account`, `classification`, and `inventory` tables and inserts sample data.
- `assignment2.sql` — the six Task 1 statements you must run to demonstrate the assignment.
- `assignment2_clean.sql` — a cleaned copy of `assignment2.sql` (use this if the main file is corrupted).

Quick run (PowerShell with `psql` available):

1. Set your database connection string into the `DATABASE_URL` env var (or pass it as an argument). Example:

```powershell
$env:DATABASE_URL = 'postgres://USER:PASSWORD@HOST:PORT/DBNAME'
./scripts/run_assignment2.ps1
```

2. The script will run `rebuild.sql`, then `assignment2.sql`, then print verification SELECTs for `classification`, `inventory`, and `account`.

GUI instructions (pgAdmin / SQLTools):
- Open a query tool connected to your target database.
- Run `database/rebuild.sql` first (creates schema & seeds data).
- Run `database/assignment2.sql` (or `assignment2_clean.sql` if you prefer the cleaned copy).
- Run the verification queries shown below to confirm the final state.

Verification queries:
```sql
SELECT * FROM classification;
SELECT inv_id, inv_make, inv_model, inv_description, inv_image, inv_thumbnail FROM inventory ORDER BY inv_id;
SELECT account_id, account_firstname, account_lastname, account_email, account_type FROM account ORDER BY account_id;
```

Recording tip for the video:
- Run `rebuild.sql` first and show the results for the verification queries.
- Then run `assignment2.sql` and show the modified/final state.
- If Render is provisioning the DB during recording, you may pause the recording and resume when the DB shows as "Ready".
