# Dev setup - PostgreSQL DB in container

```shell
podman pull postgres:13
podman run -d --name postgres13 \
-e POSTGRES_USER=postgres \
-e POSTGRES_PASSWORD=changeme \
-e POSTGRES_HOST_AUTH_METHOD=trust \
-v postgres_data:/var/lib/postgresql/data \
-p 5432:5432 \
postgres:13

podman run postgres13
```

`config/database.yml`
```yaml
---
development:
  adapter: postgresql
  host: localhost
  username: postgres
  password: changeme
  pool: 5
  database: foreman_dev

test:
  adapter: postgresql
  host: localhost
  username: postgres
  password: changeme
  pool: 5
  database: foreman_test

production:
  adapter: postgresql
  host: localhost
  username: postgres
  password: changeme
  pool: 5
  database: foreman_prod
```
