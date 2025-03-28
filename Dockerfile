# Author: ProgramZmh
# License: Apache-2.0
# Description: Dockerfile for chatnio

# Specify the platform directly if you are building for a specific architecture
FROM programzmh/chatnio:latest

WORKDIR /


# Volumes
EXPOSE 8094

# Run application
CMD ["./chat"]
