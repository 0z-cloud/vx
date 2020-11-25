#!/bin/bash
mdb_host="$"'mdb_host'
mdb_user="$"'mdb_user'
mdb_pass="$"'mdb_pass'
mdb_name="$"'mdb_name'
mdb_enable="$"'mdb_enable'
StartPage="$"'StartPage'
db_host="$"'db_host'
db_user="$"'db_user'
db_pass="$"'db_pass'
db_name="$"'db_name'
db_prefix="$"'db_prefix'
db_secret="$"'db_secret'

echo "status $ENV_STATUS"
if [ "$ENV_STATUS" = "live" ]; then

    echo "<?php
    // DO NOT MODIFY!
    $mdb_host=\"10.10.11.110\";
    $mdb_user=\"root\";
    $mdb_pass=\"12345\";
    $mdb_name=\"ogame\";
    ?>" > /ogame/config.php

    echo "<?php
    // DO NOT MODIFY!
    $StartPage=\"https://ogame.woinc.space\";
    $db_host=\"10.10.11.110\";
    $db_user=\"root\";
    $db_pass=\"12345\";
    $db_name=\"ogame\";
    $db_prefix=\"uni1_\";
    $db_secret=\"ogame\";
    $mdb_enable=\"1\";
    $mdb_host=\"10.10.11.110\";
    $mdb_user=\"root\";
    $mdb_pass=\"12345\";
    $mdb_name=\"ogame\";
    ?>" > /ogame/game/config.php

else    

    echo "<?php
    // DO NOT MODIFY!
    $mdb_host=\"10.10.0.199\";
    $mdb_user=\"root\";
    $mdb_pass=\"12345\";
    $mdb_name=\"ogame\";
    ?>" > /ogame/config.php

    echo "<?php
    // DO NOT MODIFY!
    $StartPage=\"http://localhost:1488\";
    $db_host=\"10.10.0.199\";
    $db_user=\"root\";
    $db_pass=\"12345\";
    $db_name=\"ogame\";
    $db_prefix=\"uni1_\";
    $db_secret=\"ogame\";
    $mdb_enable=\"1\";
    $mdb_host=\"10.10.0.199\";
    $mdb_user=\"root\";
    $mdb_pass=\"12345\";
    $mdb_name=\"ogame\";
    ?>" > /ogame/game/config.php
fi
echo " путь -  $local_path"
chown www-data:www-data /ogame/config.php
chown www-data:www-data /ogame/game/config.php
