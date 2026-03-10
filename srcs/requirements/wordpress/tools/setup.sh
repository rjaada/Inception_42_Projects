#!/bin/bash

mkdir -p /var/www/html
	
until mysqladmin ping -h mariadb --silent; do 
	sleep 1
done

if [ ! -f /var/www/html/wp-login.php ]; then
	wget https://wordpress.org/latest.tar.gz -P /tmp
	tar -xzf /tmp/latest.tar.gz -C /var/www/html --strip-components=1
	wp config create --dbname=$MYSQL_DATABASE --dbuser=$MYSQL_USER --dbpass=$MYSQL_PASSWORD --dbhost=mariadb --path=/var/www/html --allow-root
	wp core install --url=$WP_URL --title=$WP_TITLE --admin_user=$WP_ADMIN_USER --admin_password=$WP_ADMIN_PASSWORD --admin_email=$WP_ADMIN_EMAIL --path=/var/www/html --allow-root
	wp user create $WP_USER $WP_USER_EMAIL --role=subscriber --user_pass=$WP_USER_PASSWORD --path=/var/www/html --allow-root
fi
php-fpm8.2 -F
