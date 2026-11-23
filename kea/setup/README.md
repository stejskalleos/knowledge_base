# KEA Setup

This guide uses the test stack in this directory. It runs Kea 3.0.5,
PostgreSQL for host reservations, and Kea's HTTP API with Basic authentication.
The API is available only on `127.0.0.1:8000`.

## Requirements

- Podman and `podman-compose`
- Python 3
- The libvirt system network `foreman-isc.lan`, using bridge `virbr66`

The startup script checks that this libvirt network has no DHCP range before
starting Kea. This keeps Kea from competing with libvirt's DHCP server.

Supporting files are alongside this guide:

- `compose.yaml` — PostgreSQL, schema initialization, and Kea services
- `kea-dhcp4.conf` — sample subnet, API credentials, hooks, and database config
- `Dockerfile.admin` — builds the Kea PostgreSQL schema helper image
- `start.py` — checks the libvirt network and starts the stack

## Start Kea

Run the launcher:

```sh
python3 /home/lstejska/projects/knowledge_base/kea/kea-pr949/start.py
```

The first start builds the schema helper image, initializes the PostgreSQL
schema, and starts Kea. Later starts reuse the database and lease volumes.

Check container status and follow Kea's logs:

```sh
podman-compose -f /home/lstejska/projects/knowledge_base/kea/kea-pr949/compose.yaml ps
podman-compose -f /home/lstejska/projects/knowledge_base/kea/kea-pr949/compose.yaml logs -f kea
```

## Connect Smart Proxy

Use these settings in the PR checkout's `config/settings.d/dhcp_kea.yml`:

```yaml
:dhcp_kea_url: http://127.0.0.1:8000/
:dhcp_kea_username: review
:dhcp_kea_password: review
:dhcp_kea_verify_ssl: true
:dhcp_kea_http_timeout: 5
```

The credentials are local test values. The API binds to loopback and uses
unencrypted HTTP, so do not expose the port beyond this machine.

## Verify the API

An unauthenticated request should return `401`:

```sh
curl -i -H 'Content-Type: application/json' \
  --data '{"command":"config-get","service":["dhcp4"]}' \
  http://127.0.0.1:8000/
```

An authenticated request should return result `0` and subnet `192.168.66.0/24`:

```sh
curl -sS -u review:review -H 'Content-Type: application/json' \
  --data '{"command":"config-get","service":["dhcp4"]}' \
  http://127.0.0.1:8000/ | jq '.[0] | {result, subnets: .arguments.Dhcp4.subnet4}'
```

The configured subnet has ID `66` and pool `192.168.66.100`–`192.168.66.200`.
The host and lease command hooks are loaded, and host reservations are stored in
PostgreSQL, as required by the current [PR #949](https://github.com/theforeman/smart-proxy/pull/949).

## DHCP traffic

The Kea config listens on `virbr66`; the API is independent of DHCP traffic.
The bridge currently has no carrier, so Kea can answer API requests while it
cannot offer addresses yet. Attach a VM to the isolated libvirt network before
checking actual DHCP exchanges.

## Stop the stack

Stop Kea but leave PostgreSQL running:

```sh
podman-compose -f /home/lstejska/projects/knowledge_base/kea/kea-pr949/compose.yaml stop kea
```

Stop all services while keeping their named volumes:

```sh
podman-compose -f /home/lstejska/projects/knowledge_base/kea/kea-pr949/compose.yaml stop
```
