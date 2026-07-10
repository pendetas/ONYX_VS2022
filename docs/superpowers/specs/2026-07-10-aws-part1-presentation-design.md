# AWS Part 1 Presentation Design

## Communication job

By the end of Part 1, the lecturer should understand that the team created a controlled PostgreSQL database in Amazon RDS, migrated the complete local ONYX schema and data using a consistent Plain SQL workflow, and verified the resulting cloud records.

## Constraints and sources

- Maximum: 10 slides for Part 1.
- Every screenshot diagram receives a concise explanation and a technical justification.
- Preserve the existing ONYX Canva visual system: black background, white typography, small metadata line, dominant screenshot, numbered steps, and white justification panel.
- Use the reviewed screenshots from the Notion page `AWS DOCUMENTATION PART I`, replacing its original security-group and migration-proof images with the approved local screenshots.
- Do not expose customer records, password hashes, addresses, phone numbers, or dates of birth.

## Slide design

### Slide 1 - AWS PostgreSQL: From Creation to Verified Migration

- Purpose: Part 1 section divider.
- Content: `CREATE RDS -> MIGRATE LOCAL DATA -> VERIFY CLOUD RECORDS`.
- Visual: Minimal ONYX divider slide; no screenshot and no justification panel because it is not an evidence diagram.

### Slide 2 - PostgreSQL Provides a Compatible Cloud Target

- Screenshot: AWS RDS engine selection with PostgreSQL and Easy Create selected.
- Steps:
  1. Open Amazon RDS and start database creation.
  2. Select PostgreSQL as the database engine.
  3. Use Easy Create for the initial RDS configuration.
- Justification: PostgreSQL matches the local ONYX database engine, preserving SQL behavior, data types, and the existing dump-and-restore workflow. This reduces conversion risk and allows the same PostgreSQL tooling to be used on both sides of the migration.

### Slide 3 - The Instance Is Sized and Exposed for Controlled Access

- Screenshots: AWS instance class and additional public-access configuration, stacked vertically.
- Steps:
  1. Choose the burstable `db.t4g.micro` instance class.
  2. Enable public accessibility for the controlled remote migration.
  3. Retain PostgreSQL's standard port `5432`.
- Justification: The micro instance is sufficient for the assignment workload while limiting cloud cost. Public accessibility allows DBeaver on the development workstation to reach RDS, but it does not grant unrestricted database access; the following security-group rule limits who can connect.

### Slide 4 - The Security Group Restricts Database Access

- Screenshot: Approved inbound-rule image showing only PostgreSQL TCP `5432` from `161.142.125.27/32`.
- Steps:
  1. Select the PostgreSQL inbound-rule type.
  2. Restrict the source to the workstation's `/32` public IP.
  3. Save the rule without any `0.0.0.0/0` entry.
- Justification: A `/32` source applies least-privilege network access by allowing only the identified development workstation to initiate a PostgreSQL connection. Removing the open-internet rule reduces the attack surface while retaining the connectivity required for migration.

### Slide 5 - Migration Begins With a Consistent Local Backup

- Screenshot: DBeaver local `onyx` database with Tools -> Backup selected.
- Steps:
  1. Select the local ONYX PostgreSQL database.
  2. Open the database Tools menu.
  3. Start the PostgreSQL Backup workflow.
- Justification: Creating one database backup is safer and more repeatable than copying tables manually. It produces a single migration artifact that can carry related schema objects and records together, reducing omissions and inconsistent table states.

### Slide 6 - The Complete Public Schema Is Included

- Screenshot: DBeaver export-object selection with `public` and Complete backup enabled.
- Steps:
  1. Select the `public` schema.
  2. Keep Complete backup enabled.
  3. Continue to the backup settings.
- Justification: Exporting the complete application schema keeps tables, sequences, constraints, and their data in the same migration scope. This protects referential integrity and avoids a partial cloud database that cannot support the application correctly.

### Slide 7 - Plain SQL Creates a Portable Migration File

- Screenshot: Updated DBeaver backup settings with Plain format and `onyx_migration.sql`.
- Steps:
  1. Select Plain as the backup format.
  2. Save the output as `onyx_migration.sql`.
  3. Start the PostgreSQL dump operation.
- Justification: Plain format creates a portable SQL reconstruction script and matches the selected restore method. The explicit filename makes the migration artifact easy to identify, audit, and reuse without a format mismatch between export and restore.

### Slide 8 - The Backup Is Directed to the RDS Target

- Screenshot: DBeaver RDS connection with Tools -> Restore selected.
- Steps:
  1. Select the PostgreSQL connection that uses the RDS endpoint.
  2. Open the database Tools menu.
  3. Choose Restore to load the migration file into AWS.
- Justification: Starting Restore from the RDS connection ensures the SQL artifact is applied to the cloud target rather than the local source. This separation protects the original database and makes the direction of migration explicit.

### Slide 9 - Matching Restore Settings Recreate the Database Cleanly

- Screenshot: DBeaver restore settings using Plain format and `onyx_migration.sql`.
- Steps:
  1. Keep Plain selected to match the exported file.
  2. Choose `onyx_migration.sql` as the input.
  3. Use Clean only for this controlled initial migration, then start Restore.
- Justification: Matching the Plain export and restore formats prevents the tool from interpreting the backup incorrectly. For this initial controlled load, Clean removes stale objects before recreation, reducing duplicate-object and schema-conflict errors; it should not be used on a populated production target without a recovery plan.

### Slide 10 - The RDS Database Contains the Migrated Records

- Screenshot: Approved RDS proof image showing the table tree and populated `products` rows.
- Steps:
  1. Confirm the connection uses the Amazon RDS endpoint.
  2. Verify that the expected ONYX tables exist under `public`.
  3. Open `products` and confirm that its records are populated.
- Justification: The table tree verifies that the application schema reached RDS, while the populated product rows prove that the migration transferred actual records rather than empty structures. Together, these checks provide direct evidence that the cloud database is ready for application connectivity testing.

## Quality checks

- Keep every screenshot legible at presentation size; crop unused interface space rather than shrinking the evidence.
- Use no more than three short numbered steps per content slide.
- Keep each justification to the technical reason and demonstrated outcome.
- Ensure slide titles remain on one line.
- Preserve the original Canva design until the user explicitly approves saving the edits.
