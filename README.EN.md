# Dujiaoka Docker One-Click Deployment

## Introduction

This project provides a Docker image for deploying an open-source automated vending system, [Dujiaoka](https://github.com/assimon/dujiaoka). This project aims to offer an efficient, stable, and rapid solution.

**This image supports both AMD64 and ARM64 architectures.**

## Usage Instructions

### Docker Installation

Refer to [this tutorial](https://yeasy.gitbook.io/docker_practice/install) for installing `Docker` and `docker-compose`.

### Setting Up Dujiaoka

#### Pre-creating Directories

```bash
mkdir Shop && cd Shop
mkdir storage uploads
chmod 777 storage uploads
```

#### Editing `docker-compose.yaml`

```yaml
version: "3"

services:
  faka:
    image: ghcr.io/apocalypsor/dujiaoka:latest
    container_name: faka
    environment:
        # - INSTALL=false
        - INSTALL=true
    volumes:
      - ./env.conf:/dujiaoka/.env
      - ./uploads:/dujiaoka/public/uploads
      - ./storage:/dujiaoka/storage
    ports:
      - 127.0.0.1:56789:80
    restart: always
 
  db:
    image: mariadb:focal
    container_name: faka-data
    restart: always
    environment:
      - MYSQL_ROOT_PASSWORD=<ROOT_PASSWORD>
      - MYSQL_DATABASE=dujiaoka
      - MYSQL_USER=dujiaoka
      - MYSQL_PASSWORD=<DB_PASSWORD>
    volumes:
      - ./data:/var/lib/mysql

  redis:
    image: redis:alpine
    container_name: faka-redis
    restart: always
    volumes:
      - ./redis:/data
```

Replace placeholders like `<foobar>` with your information. Ensure these replacements align with those in the `docker-compose.yaml` file.

If you need to run certain commands every time the container starts, such as modifying a file, map `faka` as follows:

```yaml
- ./start-hook.sh:/dujiaoka/start-hook.sh
```

Pre-create and write the `start-hook.sh`, for example:

```bash
#!/bin/sh

echo "Executing start-hook ..."

# Optimize announcement style of Luna theme detail page
cp -f /dujiaoka/resources/views/luna/layouts/_notice_xs.blade.php /dujiaoka/resources/views/luna/layouts/_notice.blade.php
```

#### Editing the `.env` File

Create `env.conf`:

```ini
APP_NAME=<YOUR_APP_NAME>
APP_ENV=local
APP_KEY=<YOUR_APP_KEY>
APP_DEBUG=false
APP_URL=<YOUR_APP_URL>
#ADMIN_HTTPS=true

# Database Configuration
DB_CONNECTION=mysql
DB_HOST=db
DB_PORT=3306
DB_DATABASE=dujiaoka
DB_USERNAME=dujiaoka
DB_PASSWORD=<DB_PASSWORD>

# Redis Configuration
REDIS_HOST=redis
REDIS_PASSWORD=null
REDIS_PORT=6379

# Other Configurations...
```

If no special requirements exist, use the file as provided above and replace placeholders like `<foobar>`. For additional issues, refer to [`dujiaoka/.env.example`](https://github.com/assimon/dujiaoka/blob/master/.env.example).

### Epusdt

[Epusdt](https://github.com/assimon/epusdt) (Easy Payment Usdt) is an open-source USDT payment middleware (TRC20 network) officially provided by Dujiaoka. To add USDT receipt, include the following in your `docker-compose.yaml`:

```yaml
  usdt:
    image: ghcr.io/apocalypsor/dujiaoka:usdt
    container_name: faka-usdt
    restart: always
    volumes:
      - ./usdt.conf:/usdt/.env
    ports:
      - 127.0.0.1:51293:8000
```

Prepare and edit the `usdt.conf` configuration file in advance, referring to the [documentation](https://github.com/assimon/epusdt/blob/master/wiki/manual_RUN.md) and the [sample configuration](https://github.com/assimon/epusdt/blob/master/src/.env.example).

It is recommended to reverse-proxy the `51293` port and use a separate domain for Epusdt.

#### Starting the Service

```bash
docker-compose up -d
```

#### Reverse Proxy Configuration

```nginx
#PROXY-START/

location ^~ /
{
    proxy_pass http://127.0.0.1:56789;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header REMOTE-HOST $remote_addr;
    proxy_set_header X-Forwarded-Proto $scheme;

    add_header X-Cache $upstream_cache_status;

    proxy_set_header Accept-Encoding "";
    sub_filter "http://" "https://";
    sub_filter_once off;
}

#PROXY-END/
```

### Web Installation

When installing via the web interface, set the `host` of the database to `db` and keep the default port.

Note that after the initial installation is complete, you should change `INSTALL=true` to `INSTALL=false` in the `docker-compose.yaml` environment variables and execute the following command to apply changes:

```bash
docker-compose down && docker-compose up -d
```

# TODO

- [ ] Support for other architectures like ARM
