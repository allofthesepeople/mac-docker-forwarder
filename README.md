# mac-docker-forwarder
Hacks forwarding all exposed docker-machine ports to localhost

Requires Docker Machine to be active. (`eval "$(docker-machine env <machne-name>)"`)

To start port forwarding:
`./dm-port-forward.sh start`

And stop:
`./dm-port-forward.sh stop`

