# Self-hosted

Docker Compose structure, one folder per service. `docker.txt` lists services to
try. Real `.env` files stay out of git.

## Firefly III

The tracked files have secrets blank. Copy them next to the Compose file and fill
in `APP_KEY` (exactly 32 characters), `DB_PASSWORD`, `MYSQL_PASSWORD` and `SITE_OWNER`.

```bash
cd firefly-iii
cp firefly_iii.env.example .firefly_iii.env
cp database.env.example .database.env
docker compose up -d
```
