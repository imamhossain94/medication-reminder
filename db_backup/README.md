# Medicine database backup

This folder holds a **backup copy** of the medicine database that the app
downloads at runtime. It is a byte-for-byte copy of `medicine.db` from the
upstream project so the file can be recovered if
[`WSAyan/medicinedb`](https://github.com/WSAyan/medicinedb) ever goes offline or
changes its layout.

## Where the data comes from

| | |
|---|---|
| Source repository | <https://github.com/WSAyan/medicinedb> |
| File | [`medicine.db`](https://github.com/WSAyan/medicinedb/blob/main/medicine.db) |
| Author | WSAyan |
| License | MIT |
| Contents | ~17 500 medicine brands, ~1 400 generics, ~650 manufacturers (mostly Bangladeshi brands) |
| Tables | `brand`, `generic`, `company_name`, `indication`, `pregnancy_category`, `systemic`, `therapitic`, `therapitic_generic`, `indication_generic_index` |

The data is **not** produced by this app. It is redistributed under the MIT
license of the upstream project, and the app shows the attribution in the drawer
("Where the data comes from") and on the home screen.

## The database is NOT bundled in the APK

`medicine.db` is intentionally kept out of `pubspec.yaml`'s asset list so the
downloaded copy can be replaced independently of an app release. At runtime
`lib/services/database_downloader.dart` tries the mirrors below, in order, and
validates the result (SQLite header + expected tables) before it is installed:

1. `https://raw.githubusercontent.com/WSAyan/medicinedb/main/medicine.db`
2. `https://cdn.jsdelivr.net/gh/WSAyan/medicinedb@main/medicine.db`
3. `https://github.com/WSAyan/medicinedb/raw/main/medicine.db`

## Refreshing this backup

```bash
curl -L -o db_backup/medicine.db \
  https://raw.githubusercontent.com/WSAyan/medicinedb/main/medicine.db

# sanity check the file really is the medicine database
sqlite3 db_backup/medicine.db "SELECT COUNT(*) FROM brand;"
```

Last synced: see the commit that touched `db_backup/medicine.db`.

## Privacy note

This database only contains public, generic drug information (brand names,
generic names, manufacturers, indications, dosages). It contains **no personal
or patient data**, so it is safe to keep in a public repository. Reminders
created by a user are stored **only on the device** in a local Hive box and are
never uploaded anywhere.
