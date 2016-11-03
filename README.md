# private-registry
A private Docker Registry with built-in TLS certificate generation and HTTP Basic Auth user management.

This container was compiled following CenturyLink's [How to Secure Your Private Docker Registry](https://www.ctl.io/developers/blog/post/how-to-secure-your-private-docker-registry/) blog post and Docker's [Deploying a registry server](https://docs.docker.com/registry/deploying/) documentation.

Get the image from Docker:
```
docker pull roberto/private-registry
```
The instructions below use two Docker Compose files, `docker-compose.yml` and docker-compose-`tools.yml`, and assume these Compose files are located in a folder named `private-registry`.  They can be extracted from the Docker image with the command:
```
docker run -t -i --rm --volume $(pwd):/host roberto/private-registry /bin/sh -c 'cp /*.yml /host/'
```
## Usage
Start the registry container with docker-compose:
```
docker-compose up -d
```
The command above will generate a self-signed certificate with the name `registry`.  The certificate is located in a Docker volume named `privateregistry_registry-certs`.  The cert can then be copied from that volume to configure docker instances that want to work with that registry:
```
docker run -t -i --rm --volume privateregistry_registry-certs:/certs --volume $(pwd):/host alpine:latest cp /certs/registry.crt /host/
```
### HTTP Basic Auth
Create a user with the `htadduser` service in `tools.yml`.  For example, to add the user `oliver` with password `bad0a95b4a4ac2d7289f9d905c3b6f4eb82203b3` run the command below and restart the registry:
```
docker-compose -f docker-compose.yml -f docker-compose-tools.yml run htadduser oliver bad0a95b4a4ac2d7289f9d905c3b6f4eb82203b3
docker-compose restart registry
```
## Using a real certificate
To use real certificate, create the certs volume by running the command:
```
docker-compose up security
```
Then, assuming your real certificates are at `$(pwd)/real-certs`:
```
[0][~/Projects/docker-registry]
[berto@g6]$ ls real-certs/
registry.crt registry.csr registry.key
```
run the following command to copy the files in place:
```
docker run -t -i --rm --volume privateregistry_registry-certs:/certs --volume $(pwd)/real-certs:/host alpine:latest /bin/sh -c 'cp /host/* /certs/'
```
**NOTE**: this will overwrite the self-signed certificates
