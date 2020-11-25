#!/bin/bash

echo "------------------->----------v----------<---------"
echo "------------------->--------r-v-i--------<---------"
echo "------------------->------e-r-v-i-s------<---------"
echo "------------------->----p-e-r-v-i-s-o----<---------"
echo "MAIN START:-------->--u-p-e-r-v-i-s-o-r--<---------"
echo "------------------->s-u-p-e-r-v-i-s-o-r-d<---------"
echo "---------------------------------------------------"
# chmod 666 /app/cyrcle/cyrcle/webapp/storage/logs/*
# cd /app/cyrcle/cyrcle/webapp/
# echo "step1"

# php artisan vendor:publish --provider="Spatie\Activitylog\ActivitylogServiceProvider" --tag="migrations"

# echo "step3"

# php artisan migrate:refresh --seed

# echo "step5"

# php artisan cache:clear

# echo "step7"

# composer dump-autoload

# echo "step8"

# php artisan config:clear

# echo "step9"

# php artisan key:generate

echo "------------------->----------v----------<---------"
echo "------------------->--------r-v-i--------<---------"
echo "------------------->------e-r-v-i-s------<---------"
echo "------------------->----p-e-r-v-i-s-o----<---------"
echo "MAIN DONE :-------->--u-p-e-r-v-i-s-o-r--<---------"
echo "------------------->s-u-p-e-r-v-i-s-o-r-d<---------"
echo "---------------------------------------------------"

mkdir /run/php/
/ogame/config.sh
exec /usr/bin/supervisord
while true; do
echo "YAMI!!"
sleep 1
done

echo "All DONE"
