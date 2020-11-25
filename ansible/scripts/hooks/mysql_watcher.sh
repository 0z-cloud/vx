#!/bin/bash

watch_count_q(){
mysql --user='root' --password='ПАРОЛЬ ЗДЕСЬ!' --execute="SELECT * FROM information_schema.processlist WHERE command != 'Sleep' ORDER BY time ASC\G" | grep row | wc -l
}

export -f watch_count_q

watch -n 0.1 --exec bash -c "watch_count_q"