# docker-registry

A custom private docker registry with some UI frontends to compare (joxit preferred).

## Usage

```bash
docker-compose up joxit
```

Access the web frontends at [http://localhost:8080](http://localhost:8080)

## Maintenance

```console
docker-compose run --rm registry garbage-collect /etc/docker/registry/config.yml
```
