# Author: ProgramZmh
# License: Apache-2.0
# Description: Dockerfile for chatnio

# Specify the platform directly if you are building for a specific architecture
FROM programzmh/chatnio:latest

WORKDIR /

ENV MYSQL_HOST=br73tpwib4fv8wdhpify-mysql.services.clever-cloud.com \
    MYSQL_PORT=3306 \
    MYSQL_DB=br73tpwib4fv8wdhpify \
    MYSQL_USER=u3oofuqvr9yrph5f \
    MYSQL_PASSWORD=4gNrd9kkmrHXNBdvkoET
  
# Volumes
EXPOSE 8094

# Run application
CMD ["./chat"]
