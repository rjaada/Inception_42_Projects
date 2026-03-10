# User Documentation

## What this stack provides

This project runs a WordPress website with three services:

- **NGINX** — the web server. It listens on port 443 (HTTPS only) and is the only way to reach the site from outside. It handles TLS and forwards PHP requests to WordPress.
- **WordPress + php-fpm** — the actual website. It runs the WordPress application and processes all PHP files.
- **MariaDB** — the database. It stores all WordPress content, users, and settings.

You access everything through the browser at `https://rjaada.42.fr`. You do not interact with WordPress or MariaDB directly.

## Starting and stopping the project

From the root of the repository:

```bash
# Start everything
make

# Stop everything (containers stop, data is preserved)
make down

# Full cleanup (removes containers, volumes, images, and all data)
make clean

# Clean then rebuild from scratch
make re
```

After `make`, wait about 30 seconds for WordPress to finish installing before opening the browser.

## Accessing the website

Open your browser and go to:

```
https://rjaada.42.fr
```

Your browser will warn you about the self-signed certificate. This is expected. Click "Advanced" and then "Proceed" (or equivalent in your browser) to continue.

### Accessing the admin panel

Go to:

```
https://rjaada.42.fr/wp-admin
```

Log in with the admin credentials from your `.env` file (`WP_ADMIN_USER` and `WP_ADMIN_PASSWORD`).

## Credentials

All credentials are stored in `srcs/.env`. This file is not committed to git. Open it to find:

| Variable | Description |
|---|---|
| `MYSQL_USER` | WordPress database user |
| `MYSQL_PASSWORD` | WordPress database password |
| `WP_ADMIN_USER` | WordPress admin username |
| `WP_ADMIN_PASSWORD` | WordPress admin password |
| `WP_USER` | Second WordPress user (subscriber role) |
| `WP_USER_PASSWORD` | Second user's password |

Do not share this file or commit it to any repository.

## Checking that services are running

Run:

```bash
docker ps
```

You should see three containers running:

```
srcs-nginx-1       → port 443
srcs-wordpress-1   → port 9000
srcs-mariadb-1     → port 3306
```

If a container is missing or keeps restarting, check its logs:

```bash
docker logs srcs-nginx-1
docker logs srcs-wordpress-1
docker logs srcs-mariadb-1
```

To check that the website is actually responding:

```bash
curl -k https://rjaada.42.fr
```

The `-k` flag skips the certificate check. If you get HTML back, the site is up.
