*This project has been created as part of the 42 curriculum by rjaada.*

# Inception

## Description

Inception is a system administration project from 42. The goal is to build a small infrastructure using Docker Compose, running three services in separate containers: NGINX as the entry point with TLS, WordPress with php-fpm to serve the website, and MariaDB as the database. Everything runs on a custom Docker bridge network, and data is persisted through named volumes stored on the host machine.

The project is done entirely from scratch — no pre-built images from DockerHub, only custom Dockerfiles built on top of Debian.

## Project Description

### How Docker is used

Each service runs in its own container built from a custom Dockerfile. Docker Compose is used to define and connect all services. The Makefile drives the build and teardown.

The three containers are:
- `nginx` — the only entry point, listens on port 443 with TLSv1.2/TLSv1.3, serves static files and proxies PHP requests to php-fpm
- `wordpress` — runs php-fpm which executes the WordPress PHP files, connects to MariaDB for data
- `mariadb` — the MySQL-compatible database that stores all WordPress content

### Design choices

All three containers are on a custom bridge network called `inception`. This means they can talk to each other by service name (e.g. `mariadb`, `wordpress`) but are isolated from other Docker networks. Containers restart automatically on crash with `restart: always`.

### Virtual Machines vs Docker

A virtual machine emulates a full operating system with its own kernel, CPU allocation, and memory. It is heavy and slow to start. Docker containers share the host kernel and only isolate the process and filesystem. Containers start in seconds and use far fewer resources. The tradeoff is that Docker provides less isolation — a container escape is more dangerous than a VM escape. For this project, Docker is appropriate because we are running simple web services that do not require full OS isolation.

### Secrets vs Environment Variables

Environment variables are plain text values passed to the container at runtime, visible to any process inside the container and stored in the `docker inspect` output. Docker secrets are stored in encrypted form in Docker's internal storage and mounted as files inside the container. For this project, we use a `.env` file for environment variables. The `.env` file is never committed to git. Using Docker secrets would be the more secure approach for production, but `.env` with `.gitignore` satisfies the project requirement.

### Docker Network vs Host Network

With `network: host`, the container shares the host's network stack directly — it binds to the same IP and ports as the host machine, with no isolation. With a custom Docker bridge network, containers get their own virtual network with private IPs, and can only communicate through explicitly defined ports. We use a bridge network because it gives proper isolation between containers and allows them to reach each other by service name without exposing internal ports to the outside.

### Docker Volumes vs Bind Mounts

A bind mount maps a specific path on the host directly into the container. A named volume is managed by Docker and stored in Docker's volume directory by default. Named volumes survive `docker-compose down` and can be shared between containers. For this project, we use named volumes with the local driver configured to store data at `/home/rjaada/data/` on the host, which satisfies both the "named volumes" requirement and the "data in /home/login/data" requirement.

## Instructions

### Prerequisites

- Docker and Docker Compose installed
- `sudo` access (for creating data directories)
- Add the domain to `/etc/hosts`:
  ```
  127.0.0.1   rjaada.42.fr
  ```

### Setup

Clone the repository and create a `.env` file in `srcs/`:
```
MYSQL_DATABASE=wordpress
MYSQL_USER=wpuser
MYSQL_PASSWORD=yourpassword

WP_ADMIN_USER=rjaada
WP_ADMIN_PASSWORD=yourpassword
WP_ADMIN_EMAIL=your@email.com
WP_TITLE=yoursite
WP_URL=rjaada.42.fr

WP_USER=seconduser
WP_USER_PASSWORD=yourpassword
WP_USER_EMAIL=second@email.com
```

### Build and run

```bash
make        # creates data directories, builds images, starts containers
make down   # stops containers
make clean  # stops containers, removes volumes and images, deletes data
make re     # full rebuild from scratch
```

### Access

Once running, open `https://rjaada.42.fr` in a browser. Accept the self-signed certificate warning.

## Resources

- Docker documentation: https://docs.docker.com
- Docker Compose reference: https://docs.docker.com/compose/compose-file/
- NGINX documentation: https://nginx.org/en/docs/
- php-fpm documentation: https://www.php.net/manual/en/install.fpm.php
- MariaDB documentation: https://mariadb.com/kb/en/documentation/
- wp-cli documentation: https://wp-cli.org/
- OpenSSL manual: https://www.openssl.org/docs/manmaster/man1/openssl-req.html

### AI usage

Claude Code (claude-sonnet) was used throughout this project as a learning and debugging tool. Specifically:

- Understanding how NGINX, php-fpm, and MariaDB communicate (FastCGI protocol, TCP vs Unix socket)
- Debugging container networking issues (containers not finding each other by hostname)
- Understanding why `CMD ["bash", "script.sh"]` is problematic vs calling the script directly
- Understanding how named volumes and bind mounts differ in Docker Compose
- Debugging the MariaDB crash loop caused by running `CREATE DATABASE` on a database that already existed
- Reviewing shell scripts for container initialization
- Reading and understanding what the subject required for each file

All code was reviewed, tested, and understood before being used. Nothing was blindly copy-pasted.
