#!/bin/bash
git pull
# удаление контейнера
docker rm -f ogame mariadb  
# удаление собранных оброзов доккера
# docker rmi -f ogt mariadb
# переходим в марию
cd ../../dockerfiles/mariadb/
# собираем машу
docker build . -t mariadb
# возврвщаемся обратно
cd ../../services/ogame_php/
# собираем образ гамы
docker build . -t ogt
check_live=`ifconfig -a | grep -q '11.110' && echo 'ok' || echo 'ko'`
echo "результат $check_live"
if [ "$check_live" = "ok" ]; then
    # if run at prod
    local_path="/ogame";
    export local_path=$local_path;
    echo " путь -  $local_path"
    # запускаем машу
    docker run -d --name mariadb -p 3306:3306 -v $local_path/.mariadb:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=12345 -e ENV_STATUS=live mariadb:latest
    # запуск гамы
    docker run -d --name ogame -p 1488:1488 -e ENV_STATUS=live ogt:latest
else
    # if run at localhost    
    # объявление переменной
    local_path=`pwd`
    export local_path=$local_path;
    echo " путь -  $local_path"
    # запускаем машу
    docker run -d --name mariadb -p 3306:3306 -v $local_path/.mariadb:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=12345 -e ENV_STATUS=dev mariadb:latest
    # запуск гамы
    # docker run -d --name ogame -p 1488:1488 -e ENV_STATUS=dev ogt:latest
    docker run -d --name ogame -p 1488:1488 -v $local_path/src2:/ogame -e ENV_STATUS=dev ogt:latest
fi


docker exec -it ogame /bin/bash




 
