# private-registry
A private Docker Registry with built-in TLS certificate generation and HTTP Basic Auth user management.

This container was compiled following CenturyLink's [How to Secure Your Private Docker Registry](https://www.ctl.io/developers/blog/post/how-to-secure-your-private-docker-registry/) blog post and Docker's [Deploying a registry server](https://docs.docker.com/registry/deploying/) documentation.

Get the image from Docker:
```
docker pull roberto/private-registry
```

The instructions below use `docker-compose.yml`, which can be extracted from the Docker image with the command:
```
docker run -t -i --rm roberto/private-registry /bin/sh -c 'cat docker-compose.yml' > docker-compose.yml
```


## Usage
Every time the container is run, new TLS certificates are written and the default configuration is used.  They can be persisted, however.  Start a container and follow the steps below:
```
docker-compose run --rm registry /bin/bash
```


## Persisting configuration
The container will generate a self-signed certificate with the name `registry`.  It will also create an empty `/auth/htpasswd` file and use the default configuration in `/etc/docker/registry/config.yml`.

They can be persisted across containers by placing the configuration, certificates, and HTTP users in base64-encoded environment variables `PRIVATEREGISTRY_CONF`, `PRIVATEREGISTRY_TLS`, and `PRIVATEREGISTRY_AUTH_ENTRIES` as described in the following sections


### HTTP Basic Auth
Create a user with the `htadduser` command.  For example, to add the user `oliver` with password `bad0a95b4a4ac2d7289f9d905c3b6f4eb82203b3` run the command below in the registry container started above:
```
htadduser oliver bad0a95b4a4ac2d7289f9d905c3b6f4eb82203b3
```


### Customize configuration
You can also make any changes to `/etc/docker/registry/config.yml` with vi or any other editor in the container.


### Base64-encode config
Now, base64-encode the settings:
```
x=$(cat /etc/docker/registry/config.yml | base64); echo PRIVATEREGISTRY_CONF=$x
x=$(cd /certs; tar czf - . | base64); echo PRIVATEREGISTRY_TLS=$x
x=$(cat /auth/htpasswd | base64); echo PRIVATEREGISTRY_AUTH_ENTRIES=$x
```

**Note**: PRIVATEREGISTRY_TLS is quite long.

Paste those values into a `.env` file, which is automatically used by docker-compose.  Then, exit the run container and start the service:

```
docker-compose up -d
```
