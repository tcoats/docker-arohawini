# Arohanui

Runit, Syslog-ng and Node.js with an init script.

## initsh

The docker is started using /sbin/initsh as the master process (PID 1), it does the following:

* checks the /startup folder for any startup .sh scripts.
* starts runsvdir, runit then starts the services in the docker.
* when the docker is shutdown initsh signals all runit services to stop, then waits 2 seconds, then shuts down.
* also handles zombie processes.

## runit

runit is used for starting / stopping and logging of services.

To make runit start a service you either link or copy a sh script called "run" into:
/etc/services/[service name]/run

Nginx exmaple would be:
/etc/services/nginx/run
``` bash
#!/bin/sh -e
exec nginx -g "daemon off;" 2>&1
```
Note:
* nginx is not started as a daemon process, you should try to do this for any processes because we want runsvdir to get stdout.
* stderr is piped to stdout. '2>&1'

http://smarden.org/runit/

## startup folder

"/sbin/initsh" script checks for the existance of a directory '/startup' and will execute any scripts that end with ".sh".
Notes:
* the startup scripts run before runit services.
* if any script exits with a non-zero code the docker will exit with the same code and not start runit.

example:

This example makes docker output the message 'meh lets not run' and exits with 35 when you try to run metocean/aroha.

create /tmp/startup/kill_docker.sh with:
``` bash
echo 'meh lets not run'
exit 35
```
run docker with the /startup folder mounted.
``` bash
docker run -v /tmp/startup:/startup metocean/aroha
```
output will be
``` bash
meh lets not run
INIT ERROR: script /startup/test.sh exited with code 35
```

## logging

Processes / services started in this docker are expected to output logs to stdout. Initsh (PID 1) then pipes this back to the host running the docker.

Syslog-ng is used for piping dmesg to the initsh (PID 1).
