# docker-registry

A custom private docker registry.

## Setup

- Install [docker](https://docs.docker.com/engine/installation/linux/ubuntulinux/).
- Install [docker-compose](http://docs.docker.com/compose/install/).
- Clone this repository

## Usage

Start your stack using *docker-compose*:

    docker-compose up

Alternatively use [Vagrant](https://www.vagrantup.com/)

    vagrant up

Components:

- Docker Registry [http://localhost:80/](http://localhost:80/)

## Going Live

Configure `docker-compose up` to run on boot using the systemd unit file, i.e.

```bash
systemctl enable /path/to/docker-registry.service
systemctl start docker-registry
```

### Get certificates onto the docker client

The docker registry uses self-signed certificates. To enable access for docker clients to the registry you need to instruct the clients to trust the server certicifates. This goes like this

```bash
sudo mkdir -p /etc/docker/certs.d/<host>:5000
sudo curl -o /etc/docker/certs.d/<host>:5000/ca.crt http://<download>/certs/domain.crt
```

When using authentication, some versions of Docker also require you to trust the certificate at the OS level, cf.
[Docker still complains about the certificate when using authentication?](https://docs.docker.com/registry/insecure/#docker-still-complains-about-the-certificate-when-using-authentication).

In this case

```bash
cp certs/domain.crt /usr/local/share/ca-certificates/myregistrydomain.com.crt
update-ca-certificates
```

Generating intermediate self-signed certificates for testing pruposes is described in the docker documentation:

- [Use self-signed certificates](https://docs.docker.com/registry/insecure/#use-self-signed-certificates)

## Docker cleanup

Dockerized continous integration leaves its traces on disk. Mostly these are due to `docker pull` && and `docker build`.
Every once in a while we need to cleanup, cf. [Cleaning up docker to reclaim disk space](https://lebkowski.name/docker-volumes/).

Manual cleanup

```bash
sudo ./cleanup-docker.sh
```

Setup as a cron job each hour `sudo crontab -e`

```bash
0 * * * * /path/.../cleanup_docker.sh
```

## FAQ

### On Windows i get VirtualBox error: VTX not available. What's wrong?

This is a known problem when using VirtualBox and Hyper-V on Windows.
Right now there seems to be no other workaround than to temporaily disable Hyper-V.
Using `bcdedit` seems to be the best option for this, cf. [SuperUser - Convenient way to enable/disable Hyper-V in Windows 8](http://superuser.com/a/642027/459122)

    bcdedit /set hypervisorlaunchtype off

### Proxy: On clean Ubuntu install has timeouts, connection errors or hangs

If it works on Vagrant using [vagrant-proxyconf](https://github.com/tmatilai/vagrant-proxyconf), check your proxy configuration.
You should at least have set up `apt` and environment like this

- Environment: The file `/etc/environment` should contain

```conf
HTTP_PROXY=http://proxy:3128
HTTPS_PROXY=http://proxy:3128
FTP_PROXY=
NO_PROXY="localhost,127.0.0.1,.company.com"
http_proxy=http://proxy:3128
https_proxy=http://proxy:3128
ftp_proxy=
no_proxy="localhost,127.0.0.1,.company.com"
```

- User profiles (optional): create or append script `/etc/profile.d/proxy.sh` with

```conf
export {HTTP,HTTPS,FTP}_PROXY=http://proxy:3128
export NO_PROXY="localhost,127.0.0.1,.company.com"
export {http,https,ftp}_proxy=http://proxy:3128
export no_proxy="localhost,127.0.0.1,.company.com"
```

  **Note:** be sure to include both cases, i.e. include also the the obsolete in capitals (`HTTP_PROXY`) as some older packages and scripts still rely on this

- Docker Service:

  Create a systemd drop-in configuration as described here [Control and configure Docker with systemd#HTTP](https://docs.docker.com/engine/admin/systemd/#/http-proxy), i.e. set content of `/etc/systemd/system/docker.service.d/http-proxy.conf` to

```conf
[Service]
Environment="HTTP_PROXY=http://proxy:3128"
Environment="HTTPS_PROXY=http://proxy:3128"
Environment="NO_PROXY=127.0.0.1,localhost,.company.com"
Environment="http_proxy=http://proxy:3128"
Environment="https_proxy=http://proxy:3128"
Environment="no_proxy=127.0.0.1,localhost,.company.com"
```
