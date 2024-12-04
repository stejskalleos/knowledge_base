# Debugging Foreman

Configure logging
```
foreman-installer --foreman-logging-level "debug" --foreman-proxy-log-level "DEBUG"
foreman-installer --foreman-logging-level "error" --foreman-proxy-log-level "ERROR"
```

Logs
```
/var/log/foreman/production.log
/var/log/foreman-installer/<scenario>.log
/var/log/foreman-maintain/foreman-maintain.log
/var/log/foreman-proxy/proxy.log

foreman-rake log
```
