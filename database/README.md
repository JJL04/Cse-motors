Database rebuild and verification
================================

This folder contains two SQL files for Assignment 2:

- `rebuild.sql` — creates the custom type, the `classification`, `inventory`, and 0`account` tables, inserts sample data, and runs the replacement and image-path updates from Task 1.
- `assignment2.sql` — contains the six Task 1 queries (insert Tony Stark, update to Admin, delete Tony, description replace for GM Hummer, select join for Sport classification, update image paths).

Quick run (PowerShell with `psql` available):

1. Set your database connection string into the `DATABASE_URL` env var (or pass it as argument):

```powershell
$env:DATABASE_URL = 'postgres://USER:PASSWORD@HOST:PORT/DBNAME'
./scripts/run_assignment2.ps1
```

2. The script will run `rebuild.sql`, then `assignment2.sql`, then print SELECT output for `classification`, `inventory`, and `account` tables for verification.

pgAdmin / SQLTools instructions:

- Open a query tool connected to your target database.
- Open `database/rebuild.sql` and execute it (this creates types/tables and inserts sample data).
- Open `database/assignment2.sql` and execute it.
- Run the following verification queries:
  - `SELECT * FROM classification;`
  - `SELECT inv_id, inv_make, inv_model, inv_description, inv_image, inv_thumbnail FROM inventory ORDER BY inv_id;`
  - `SELECT account_id, account_firstname, account_lastname, account_email, account_type FROM account ORDER BY account_id;`

Recording tip for the video:
- Run the `rebuild.sql` file first, then show the SELECT results. Then run `assignment2.sql` (or show the modified data) so the grader can see the final state. You can pause the recording while Render provisions the DB.
