# php-apache-mariadb

source code:- [emyployee-record-management](https://phpgurukul.com/employee-record-management-system-in-php-and-mysql/)
Direct download link- [download 📥](https://phpgurukul.com/wp-content/uploads/2019/02/Employee-Record-Management-System-Project.zip)

## Installation

### create own network

```bash
docker network create my-network-erms
```

### run container

```bash
docker compose up -d
```

# Manual

### install required packages

`sudo apt install php php-fpm php-mysql`

webserver,database and php-fpm must be run in place.

_nginx config for path based serve_

```bash
server {
    listen 80;
    listen [::]:80;
    server_name erms.example.com www.erms.example.com;

    root /var/www/html/erms;
    index index.php index.html index.htm;

    location ~ \.php$ {
    include snippets/fastcgi-php.conf;
    fastcgi_pass unix:/run/php/php8.3-fpm.sock;  # adjust PHP version if needed
    fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    include fastcgi_params;
    }
    location ~ /\.ht {
    deny all;
    }
}
```

###
