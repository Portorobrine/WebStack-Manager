#!/bin/bash
set -e

# Initialiser la base de données si elle n'existe pas
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initialisation de la base de données MariaDB..."
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql

    # Démarrer MariaDB temporairement pour la configuration
    mysqld --user=mysql --skip-networking --socket=/tmp/mysql_init.sock &
    mysql_pid=$!

    # Attendre que MariaDB soit prêt
    until mysqladmin --socket=/tmp/mysql_init.sock ping >/dev/null 2>&1; do
        sleep 1
    done

    # Configuration initiale
    mysql --socket=/tmp/mysql_init.sock <<-EOSQL
        DELETE FROM mysql.user WHERE user='';
        DELETE FROM mysql.user WHERE user='root' AND host NOT IN ('localhost', '127.0.0.1', '::1');
        DROP DATABASE IF EXISTS test;
        DELETE FROM mysql.db WHERE db='test' OR db='test\\_%';

        SET PASSWORD FOR 'root'@'localhost' = PASSWORD('${MARIADB_ROOT_PASSWORD}');
        GRANT ALL ON *.* TO 'root'@'%' IDENTIFIED BY '${MARIADB_ROOT_PASSWORD}' WITH GRANT OPTION;

        CREATE DATABASE IF NOT EXISTS ${MARIADB_DATABASE};
        CREATE USER IF NOT EXISTS '${MARIADB_USER}'@'%' IDENTIFIED BY '${MARIADB_PASSWORD}';
        GRANT ALL PRIVILEGES ON ${MARIADB_DATABASE}.* TO '${MARIADB_USER}'@'%';

        FLUSH PRIVILEGES;
EOSQL

    # Arrêter MariaDB temporaire
    mysqladmin --socket=/tmp/mysql_init.sock shutdown
    wait $mysql_pid

    echo "Initialisation terminée."
fi

# Démarrer MariaDB normalement
exec mysqld --user=mysql "$@"
