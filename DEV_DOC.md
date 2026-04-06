# Developer Documentation

## Prerequisites

- Docker Engine installed
- Docker Compose v2 installed (the `docker-compose` command)
- `sudo` access on the host (needed to create and delete data directories)
- Git

## Setting up from scratch

### 1. Clone the repository

```bash
git clone <your-repo-url>
cd Inception
```

### 2. Create the .env file

The `.env` file is not in the repository (it is gitignored). You need to create it manually at `srcs/.env`:

```bash
touch srcs/.env
```

Fill it with the following variables:

```env
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

The admin username must not contain "admin" or "administrator".

### 3. Add the domain to /etc/hosts

```bash
echo "127.0.0.1   rjaada.42.fr" | sudo tee -a /etc/hosts
```

## Building and launching

```bash
make
```

This command does three things:
1. Creates `/home/rjaada/data/wordpress_files` and `/home/rjaada/data/wordpress_db` on the host
2. Builds the Docker images from the Dockerfiles
3. Starts all containers in detached mode

The first build takes a few minutes because it downloads Debian packages. On subsequent runs it uses the Docker build cache and is faster.

## Makefile targets

| Target | What it does |
|---|---|
| `make` | Creates data dirs, builds images, starts containers |
| `make down` | Stops and removes containers and network (data is kept) |
| `make clean` | Stops containers, removes volumes (`-v`), prunes all Docker images and cache, deletes data directories from host |
| `make re` | Runs `clean` then `all` — full rebuild from scratch |

> Note: `make clean` uses `docker-compose down -v` which removes the named volumes. Without `-v`, the volumes stay registered in Docker with stale paths, which breaks the next `make`.

## Container management

```bash
# See running containers
docker ps

# See logs of a specific container
docker logs srcs-nginx-1
docker logs srcs-wordpress-1
docker logs srcs-mariadb-1

# Follow logs in real time
docker logs -f srcs-wordpress-1

# Open a shell inside a running container
docker exec -it srcs-wordpress-1 bash
docker exec -it srcs-mariadb-1 bash
docker exec -it srcs-nginx-1 bash

# Check admin/sub
docker exec -it srcs-wordpress-1 wp user list --allow-root --path=/var/www/html

# Check all volumes
docker volume ls

# Inspect a volume
docker volume inspect srcs_wordpress_db
docker volume inspect srcs_wordpress_files
```

## Data persistence

All persistent data lives in two named volumes:

| Volume | Mount inside container | Path on host |
|---|---|---|
| `srcs_wordpress_db` | `/var/lib/mysql` | `/home/rjaada/data/wordpress_db` |
| `srcs_wordpress_files` | `/var/www/html` | `/home/rjaada/data/wordpress_files` |

The volumes use the `local` driver with `type: none` and `o: bind`, which tells Docker to store the data at the specified host path instead of Docker's default volume directory.

After `make down`, the data directories still exist on disk and the containers will pick them up on the next `make`. The WordPress setup script checks for `wp-login.php` before running the install — if the file already exists, it skips the installation and goes straight to starting php-fpm.

After `make clean`, the data directories are deleted and the volumes are removed. The next `make` starts completely fresh.

## Project structure

```
Inception/
├── Makefile
├── README.md
├── USER_DOC.md
├── DEV_DOC.md
└── srcs/
    ├── .env                          # not in git
    ├── docker-compose.yml
    └── requirements/
        ├── mariadb/
        │   ├── Dockerfile
        │   ├── conf/50-server.cnf    # binds MariaDB to 0.0.0.0
        │   └── tools/init.sh         # creates DB and user, then starts MariaDB
        ├── wordpress/
        │   ├── Dockerfile
        │   ├── conf/www.conf         # php-fpm pool config, listen on TCP 0.0.0.0:9000
        │   └── tools/setup.sh        # waits for DB, installs WordPress, starts php-fpm
        └── nginx/
            ├── Dockerfile            # generates self-signed TLS cert
            └── conf/nginx.conf       # HTTPS only, FastCGI pass to wordpress:9000
```

## Network

All containers are on a Docker bridge network called `inception`. Containers reach each other by service name:

- NGINX connects to WordPress via `wordpress:9000` (FastCGI)
- WordPress connects to MariaDB via `mariadb:3306` (MySQL protocol)

`network: host` and `--link` are not used. The `networks:` key is defined explicitly in `docker-compose.yml`.
