# 独角数卡(发卡) Docker 一键部署

## 简介

本项目提供了一个用于自动化售货的开源系统——[独角数卡](https://github.com/assimon/dujiaoka)基于Docker的一键部署。本项目致力于提供一个高效、稳定且快速的解决方案，帮助用户轻松搭建自己的发卡站。

**本镜像已全面支持AMD64/ARM64。**

> ~~更详细的教程：[如何优雅地搭建自己的发卡站](https://blog.dov.moe/posts/49102/)~~ 已过时

## 使用说明

### Docker 安装

参考[该教程](https://yeasy.gitbook.io/docker_practice/install)，安装好`Docker`和`docker-compose`。

### 独角数卡搭建

#### 预创建文件夹

```bash
mkdir Shop && cd Shop
mkdir storage uploads
chmod 777 storage uploads
```

#### 编辑 `docker-compose.yaml`

```yaml
version: "3"

services:
  faka:
    image: ghcr.io/apocalypsor/dujiaoka:latest
    # 国内服务器可以用: hkccr.ccs.tencentyun.com/apocalypsor/dujiaoka:latest
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
**注意：首次启动务必设置`INSTALL=true`，完成网页端安装后再将其改为`false`！**

请自行将形如`<foobar>`的变量替换为自己的信息，以下的替换要与`docker-compose.yaml`文件中相同。

如果需要每次启动容器都运行某些命令，例如修改某个文件，则`faka`需进行如下映射：

```yaml
- ./start-hook.sh:/dujiaoka/start-hook.sh
```

`start-hook.sh`需要提前创建并写好，例如：

```bash
#!/bin/sh

echo "Executing start-hook ..."

# Luna主题的详情页公告样式优化
cp -f /dujiaoka/resources/views/luna/layouts/_notice_xs.blade.php /dujiaoka/resources/views/luna/layouts/_notice.blade.php
```

#### 编辑 `.env` 文件

创建`env.conf`：

```ini
APP_NAME=<YOUR_APP_NAME>
APP_ENV=local
APP_KEY=<YOUR_APP_KEY>
APP_DEBUG=false
APP_URL=<YOUR_APP_URL>
#ADMIN_HTTPS=true

LOG_CHANNEL=stack

# 数据库配置
DB_CONNECTION=mysql
DB_HOST=db
DB_PORT=3306
DB_DATABASE=dujiaoka
DB_USERNAME=dujiaoka
DB_PASSWORD=<DB_PASSWORD>

# redis配置
REDIS_HOST=redis
REDIS_PASSWORD=
REDIS_PORT=6379

BROADCAST_DRIVER=log
SESSION_DRIVER=file
SESSION_LIFETIME=120


# 缓存配置
# file为磁盘文件  redis为内存级别
# redis为内存需要安装好redis服务端并配置
CACHE_DRIVER=redis

# 异步消息队列
# sync为同步  redis为异步
# 使用redis异步需要安装好redis服务端并配置
QUEUE_CONNECTION=redis

# 后台语言
## zh_CN 简体中文
## zh_TW 繁体中文
## en    英文
DUJIAO_ADMIN_LANGUAGE=zh_CN

# 后台登录地址
ADMIN_ROUTE_PREFIX=/admin
```

如果没有特殊需求可以直接用我上面给的文件，并替换形如`<foobar>`的变量即可。有其他问题可以参考[`dujiaoka/.env.example`](https://github.com/assimon/dujiaoka/blob/master/.env.example)。

### Epusdt

[Epusdt](https://github.com/assimon/epusdt) (Easy Payment Usdt) 是独角数卡官方的开源USDT支付中间件(TRC20网络)，如果要添加Epusdt收款，需要在`docker-compose.yaml`中添加以下项：

```yaml
  usdt:
    image: ghcr.io/apocalypsor/dujiaoka:usdt
    # 国内服务器可以用 hkccr.ccs.tencentyun.com/apocalypsor/dujiaoka:usdt
    container_name: faka-usdt
    restart: always
    volumes:
      - ./usdt.conf:/usdt/.env
    ports:
      - 127.0.0.1:51293:8000
```

同时要在目录下提前编辑好`usdt.conf`配置文件，参考[文档](https://github.com/assimon/epusdt/blob/master/wiki/manual_RUN.md)和[参考配置](https://github.com/assimon/epusdt/blob/master/src/.env.example)。

其中`51293`端口也最好反代，建议Epusdt用单独的域名。

> Epusdt的搭建可以参考下[这篇博客](https://www.ioiox.com/archives/167.html)，同样是用的本镜像。

### TokenPay

[TokenPay](https://github.com/LightCountry/TokenPay) 是一款同时支持动态和静态收款地址收取TRX、USDT-TRC20、ETH系列区块链所有代币的支付解决方案，非常好用，如果要添加TokenPay收款，需要在`docker-compose.yaml`中添加以下项：

```yaml
  faka-tokenpay:
    image: ghcr.io/apocalypsor/dujiaoka:tokenpay
    container_name: faka-tokenpay
    restart: always
    volumes:
      - ./tokenpay/TokenPay.db:/app/TokenPay.db
      - ./tokenpay/appsettings.json:/app/appsettings.json
      # - ./tokenpay/EVMChains.json:/app/EVMChains.json
    ports:
      - 127.0.0.1:52939:80
```

数据库文件要提前创建好：
```bash
mkdir tokenpay
touch ./tokenpay/TokenPay.db
touch ./tokenpay/appsettings.json
```

同时要在目录下提前编辑好`tokenpay/appsettings.json`配置文件，参考[文档](https://github.com/LightCountry/TokenPay/blob/master/Wiki/appsettings.md)。

其中`52939`端口也最好反代，建议TokenPay用单独的域名。

### 启动服务

```bash
docker-compose up -d
```

### 反代配置

**务必添加sub_filter的两行，否则Https下会出现混合内容问题。**


```nginx
#PROXY-START/

location ^~ /
{
    proxy_pass http://127.0.0.1:56789;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header REMOTE-HOST $remote_addr;
    proxy_set_header X-Forwarded-Proto  $scheme;

    add_header X-Cache $upstream_cache_status;

    proxy_set_header Accept-Encoding "";
    sub_filter "http://" "https://";
    sub_filter_once off;
}

#PROXY-END/
```

### 网页端安装

网页端安装时数据库的`host`填 `db`，端口保持默认。

还需要注意的是，首次进入安装并完成后，需要将`docker-compose.yaml`环境变量中的`INSTALL=true`改为`INSTALL=false`，然后运行以下命令使其生效：

```bash
docker-compose down && docker-compose up -d
```

独角数卡添加TokenPay要自行添加路由，可以参考[文档1](https://github.com/LightCountry/TokenPay/tree/master/Plugs/dujiaoka)和[文档2](https://github.com/LightCountry/TokenPay/tree/master/Plugs/dujiaoka%20-%20%E6%89%AB%E7%A0%81%E7%89%88%E6%9C%AC)。

# TODO
- [x] 支持 arm 等其他架构
