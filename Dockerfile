## Dockerfile for eth-net-intelligence-api (build from git).
##
## Build via:
#
# `docker build -t ethnetintel:latest .`
#
## Run via:
#
# `docker run -v <path to app.json>:/home/ethnetintel/eth-net-intelligence-api/app.json ethnetintel:latest`
#
## Make sure, to mount your configured 'app.json' into the container at
## '/home/ethnetintel/eth-net-intelligence-api/app.json', e.g.
## '-v /path/to/app.json:/home/ethnetintel/eth-net-intelligence-api/app.json'
## 
## Note: if you actually want to monitor a client, you'll need to make sure it can be reached from this container.
##       The best way in my opinion is to start this container with all client '-p' port settings and then 
#        share its network with the client. This way you can redeploy the client at will and just leave 'ethnetintel' running. E.g. with
##       the python client 'pyethapp':
##
#
# `docker run -d --name ethnetintel \
# -v /home/user/app.json:/home/ethnetintel/eth-net-intelligence-api/app.json \
# -p 0.0.0.0:30303:30303 \
# -p 0.0.0.0:30303:30303/udp \
# ethnetintel:latest`
#
# `docker run -d --name pyethapp \
# --net=container:ethnetintel \
# -v /path/to/data:/data \
# pyethapp:latest`
#
## If you now want to deploy a new client version, just redo the second step.


FROM node:20-bookworm-slim

WORKDIR /home/ethnetintel

RUN apt-get update && \
    apt-get install -y --no-install-recommends git ca-certificates && \
    rm -rf /var/lib/apt/lists/*

RUN useradd -m -d /home/ethnetintel -s /bin/bash ethnetintel && \
    chown -R ethnetintel:ethnetintel /home/ethnetintel

USER ethnetintel

RUN git clone https://github.com/cubedro/eth-net-intelligence-api /home/ethnetintel/eth-net-intelligence-api && \
    cd /home/ethnetintel/eth-net-intelligence-api && \
    npm install && \
    npm install -g pm2

RUN printf '#!/bin/bash\nset -e\ncd /home/ethnetintel/eth-net-intelligence-api\npm2 start ./app.json\ntail -f /home/ethnetintel/.pm2/logs/node-app-out-0.log\n' > /home/ethnetintel/startscript.sh && \
    chmod +x /home/ethnetintel/startscript.sh

ENTRYPOINT ["/home/ethnetintel/startscript.sh"]
