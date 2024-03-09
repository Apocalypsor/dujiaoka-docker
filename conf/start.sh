#!/bin/sh

if [ -f "/dujiaoka/.env" ]; then
    if [ ! -d "./storage/app" ]; then
        mv -n storage_bak/* storage/
    fi

    # Set permissions
    if [ -d "./storage" ]; then
        chown -R application ./storage
    fi

    if [ -d "./uploads" ]; then
        chown -R application ./uploads
    fi

    if [ "$INSTALL" != "true" ]; then
        echo "ok" > install.lock
    else
        sed -i "s/INSERT INTO \`pays\` VALUES (26,'BNB', 'tokenpay-bnb'/INSERT INTO \`pays\` VALUES (29,'BNB', 'tokenpay-bnb'/" /dujiaoka/database/sql/install.sql
        sed -i "s/INSERT INTO \`pays\` VALUES (27,'USDT-BSC', 'tokenpay-usdt-bsc'/INSERT INTO \`pays\` VALUES (30,'USDT-BSC', 'tokenpay-usdt-bsc'/" /dujiaoka/database/sql/install.sql
        sed -i "s/INSERT INTO \`pays\` VALUES (28,'USDC-BSC', 'tokenpay-usdc-bsc'/INSERT INTO \`pays\` VALUES (31,'USDC-BSC', 'tokenpay-usdc-bsc'/" /dujiaoka/database/sql/install.sql
        sed -i "s/INSERT INTO \`pays\` VALUES (26,'MATIC', 'tokenpay-matic'/INSERT INTO \`pays\` VALUES (32,'MATIC', 'tokenpay-matic'/" /dujiaoka/database/sql/install.sql
        sed -i "s/INSERT INTO \`pays\` VALUES (27,'USDT-Polygon', 'tokenpay-usdt-polygon'/INSERT INTO \`pays\` VALUES (33,'USDT-Polygon', 'tokenpay-usdt-polygon'/" /dujiaoka/database/sql/install.sql
        sed -i "s/INSERT INTO \`pays\` VALUES (28,'USDC-Polygon', 'tokenpay-usdc-polygon'/INSERT INTO \`pays\` VALUES (34,'USDC-Polygon', 'tokenpay-usdc-polygon'/" /dujiaoka/database/sql/install.sql
    fi

    # Run start hooks
    echo "Running start hooks..."
    /dujiaoka/start-hook.sh
    echo "Start hooks completed."

    php artisan clear-compiled

    supervisord -c /etc/supervisor/conf.d/supervisord.conf
else
    echo "配置文件不存在，请根据文档修改配置文件！"
fi
