# Supabase Database & Backend Architecture
**Project**: Belagavi Property (Platform Brand: **PropertyHub**)

## 1. Directory Structure
```
supabase/
├── config.toml                 # Supabase project configuration
├── README.md                   # Backend documentation & operational playbooks
└── migrations/
    ├── 00001_create_enum_types.sql
    ├── 00002_create_profiles_table.sql
    ├── 00003_create_properties_table.sql
    ├── 00004_create_property_media_table.sql
    └── 00005_create_storage_buckets.sql
```

## 2. Migration CLI Playbook

### Local Migration Execution
1. Install Supabase CLI:
   ```bash
   brew install supabase/tap/supabase
   ```
2. Start local Supabase container:
   ```bash
   supabase start
   ```
3. Apply pending migrations:
   ```bash
   supabase db reset
   ```

### Staging & Production Deployment
1. Link to remote project:
   ```bash
   supabase link --project-ref <your-supabase-project-id>
   ```
2. Push migrations to cloud database:
   ```bash
   supabase db push
   ```

---

## 3. Storage Architecture

| Bucket Name | Access Level | Description |
|---|---|---|
| `property-media` | Public | Property photos, 360 virtual tour assets, floor plans |
| `user-avatars` | Public | Profile pictures of buyers, sellers, brokers, builders |
| `property-documents` | Private | Sensitive legal certificates, NA approvals, title deeds |

---

## 4. Backup & Disaster Recovery Strategy

### Daily Database Backups
- Supabase performs automatic daily physical backups.
- Backups are stored in geo-redundant object storage.

### Point-in-Time Recovery (PITR)
- Enterprise database plan enables WAL (Write-Ahead Logging) archiving.
- Allows point-in-time recovery to any second within the past 7 to 30 days.

### Manual SQL Dumps
- Run a full database logical backup:
  ```bash
  supabase db dump --linked --data-only -f supabase/backups/backup_$(date +%Y%m%d).sql
  ```
