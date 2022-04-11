# Invoice Ninja Dockerfile

This is a self contained docker image running the required dependencies to get [Invoice Ninja](https://github.com/invoiceninja/invoiceninja) working in a docker container.

# Build

```
git clone https://github.com/mckinnon81/docker-invoiceninja
docker build .
```

# Running

## Docker

```
docker run -d \
-p 8800:80 \
-e DB_HOST=mariadb \
-e DB_USER=ninja # Database Username\
-e DB_PASS=ninja # Database Password \
-e DB_DATABASE=ninja # Database Name \
-e APP_URL=http://invoiceninja # URL for Invoice Ninja  \
-e PROTOCOL=http|https # Set PROTOCOL to http or https \
-e IN_USER_EMAIL=user@email.com # You're email address for User Login \
-e IN_PASSWORD=password # Set User's Password
```


## Docker Compose

Use the supplied `docker-compose.yml` which includes MariaDB. If you are using an external database, remove the database and network section from the compose file.

```
docker-compose up -d
```
