#!/bin/bash
set -e

in_error() {
    in_log ERROR "$@" >&2
    exit 1
}

#checking for defailt .env file
if [[ ! -f /var/www/html/.env ]]
then
    echo "env file now found - using example"
    cp /var/www/html/.env.example /var/www/html/.env
    echo -e "\nPRECONFIGURED_INSTALL=true" >> /var/www/html/.env
fi

#check if APP_URL set
if [ "${APP_URL}" ];
    then
    echo "Running config - URL set"
    sed -i "s|APP_URL=http://localhost|APP_URL=${APP_URL}|g" /var/www/html/.env
    sed -i '/^APP_URL=.*/a TRUSTED_PROXIES='*' \n' /var/www/html/.env
    sed -i '/^APP_URL=.*/a SESSION_ENCRYPT=false \n' /var/www/html/.env
    sed -i '/^APP_URL=.*/a SESSION_SECURE=false \n' /var/www/html/.env
fi

if [ "${PROTOCOL}" == "https" ];
then
    sed -i '/^APP_URL=.*/a REQUIRE_HTTPS=true \n' /var/www/html/.env
elif [ "${PROTOCOL}" == "http" ]
then
    sed -i '/^APP_URL=.*/a REQUIRE_HTTPS=false \n' /var/www/html/.env
fi

# check to see if db_user is set, if it is then run seds and if not then leave them
if [ "${DB_USER}" ];
    then
    echo "Running config - db_user set"
    ESCAPED_PASSWORD=$(sed -e 's/[$\/&]/\\&/g' <<< $DB_PASS)
    sed -i "s/DB_HOST=localhost/DB_HOST=${DB_HOST}/g" /var/www/html/.env
    sed -i "s/DB_DATABASE=ninja/DB_DATABASE=${DB_DATABASE}/g" /var/www/html/.env
    sed -i "s/DB_USERNAME=ninja/DB_USERNAME=${DB_USER}/g" /var/www/html/.env
    sed -i "s/DB_PASSWORD=ninja/DB_PASSWORD=${ESCAPED_PASSWORD}/g" /var/www/html/.env
fi

php artisan optimize
php artisan migrate --force

# If first IN run, it needs to be initialized
IN_INIT=$(php artisan tinker --execute='echo Schema::hasTable("accounts") && !App\Models\Account::all()->first();')
if [ "$IN_INIT" == "1" ]; then
  php artisan db:seed --force

  # Build up array of arguments...
  if [[ ! -z "${IN_USER_EMAIL}" ]]; then
      email="--email ${IN_USER_EMAIL}"
  fi

  if [[ ! -z "${IN_PASSWORD}" ]]; then
      password="--password ${IN_PASSWORD}"
  fi

  php artisan ninja:create-account $email $password

fi

#Fix Permissions
echo "Fix Permissions"
chown -R nginx:nginx /var/www/html/storage/
chmod -R 775 /var/www/html/storage/


echo "Invoice Ninja ready"
exec "$@"
