# Smart Proxy & Redfish
Development setup.

## Smart Proxy configuration

`config/settings.d/bmc.yml`
```yaml
---
:enabled: true
:bmc_default_provider: redfish
:redfish_verify_ssl: false
```

## Download sample Red Fish mocks
https://www.dmtf.org/dsp/DSP2043

## Redfish Mockup Server

Installation
```shell
git clone git@github.com:DMTF/Redfish-Mockup-Server.git
pip install -r requirements.txt
```

Run the server
```shell
python ./redfishMockupServer.py -H "localhost" --port 8000 --ssl --cert ~/path/to/cert --key ~/path/to/key

python ./redfishMockupServer.py -H "localhost" --port 8000 \
  --ssl \
  --cert ~/konfig/ssl/ssl_cert.pem \
  --key ~/konfig/ssl/ssl_key.pem \
  --short-form \
  --dir ~/Downloads/DSP2043_2025.2/public-compose-action
```

## Call Smart Proxy
```shell
curl -X GET "http://localhost:8080/bmc/$REDFISH_SERVER:$PORT/test" --user admin:changeme

curl --user admin:changeme \
  -X PUT \
  -H "Content-Type: application/json" \
  -d '{}' \
  "http://localhost:8080/bmc/$REDFISH_SERVER:$PORT/chassis/power/cycle"
```

