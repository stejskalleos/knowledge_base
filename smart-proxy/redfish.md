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

## Redfish Mockup Server

Installation
```shell
git clone git@github.com:DMTF/Redfish-Mockup-Server.git
pip install -r requirements.txt
```

Run the server
```shell
python ./redfishMockupServer.py -H "localhost" -p 8000 -s --cert ~/path/to/cert --key ~/path/to/key
```

## Call Smart Proxy
```shell
curl -X GET "http://localhost:8080/bmc/localhost:8000/test" --user admin:changeme
```

