<?php

// Проверить, если файл конфигурации отсутствует - редирект на страницу установки игры.
if ( !file_exists ("../config.php"))
{
    echo "<html><head><meta http-equiv='refresh' content='0;url=../install.php' /></head><body></body></html>";
    exit ();
}

require_once "../config.php";
require_once "../db.php";

require_once "../uni.php";
require_once "../prod.php";
require_once "../planet.php";
require_once "../bot.php";
require_once "../user.php";
require_once "../queue.php";
require_once "../debug.php";

// Соединиться с базой данных
dbconnect($db_host, $db_user, $db_pass, $db_name);
dbquery("SET NAMES 'utf8';");
dbquery("SET CHARACTER SET 'utf8';");
dbquery("SET SESSION collation_connection = 'utf8_general_ci';");

// Login - Вызывается с главной страницы, после регистрации или активации нового пользователя.
function Login2 ( $login, $pass, $passmd="", $from_validate=0 )
{
    global $db_prefix, $db_secret;

    $unitab = LoadUniverse ();
    $uni = $unitab['num'];

    ob_start ();

    if  ( $player_id = CheckPassword ($login, $pass, $passmd ) )
    {
        // Пользователь заблокирован?
        $user = LoadUser ( $player_id );
        if ($user['banned'])
        {
            UpdateLastClick ( $player_id );        // Обновить активность пользователя, чтобы можно было продлять удаление.
            echo "<html><head><meta http-equiv='refresh' content='0;url=".hostname()."game/reg/errorpage.php?errorcode=3&arg1=$uni&arg2=$login&arg3=".$user['banned_until']."' /></head><body></body>";
            ob_end_flush ();
            exit ();
        }

        $lastlogin = time ();
        // Создать приватную сессию.
        $prsess = md5 ( $login . $lastlogin . $db_secret);
        // Создать публичную сессию
        $sess = substr (md5 ( $prsess . sha1 ($pass) . $db_secret . $lastlogin), 0, 12);

        // Записать приватную сессию в кукисы и обновить БД.
        setcookie ( "prsess_".$player_id."_".$uni, $prsess, time()+24*60*60, "/" );
        $query = "UPDATE ".$db_prefix."users SET lastlogin = $lastlogin, session = '".$sess."', private_session = '".$prsess."' WHERE player_id = $player_id";
        dbquery ($query);

        // Записать IP-адрес.
        $ip = $_SERVER['REMOTE_ADDR'];
        $query = "UPDATE ".$db_prefix."users SET ip_addr = '".$ip."' WHERE player_id = $player_id";
        dbquery ($query);

        //echo "ID пользователя: $player_id<br>Приватная сессия: $prsess<br>Публичная сессия: $sess<br>IP-адрес: $ip";

        // Выбрать Главную планету текущей.
        $query = "SELECT * FROM ".$db_prefix."users WHERE session = '".$sess."'";
        $result = dbquery ($query);
        $user = dbarray ($result);
        SelectPlanet ($player_id, $user['hplanetid']);

        // Задание глобальной отгрузки игроков, чистки виртуальных ПО, чистки уничтоженных планет, пересчёт статистики альянсов и прочие глобальные события
        AddReloginEvent ();
        AddCleanDebrisEvent ();
        AddCleanPlanetsEvent ();
        AddCleanPlayersEvent ();
        AddRecalcAllyPointsEvent ();

        // Задание пересчёта очков игрока.
        AddUpdateStatsEvent ();
        AddRecalcPointsEvent ($player_id);

        // Редирект на Обзор Главной планеты.
        header ( "Location: ".hostname()."game/index.php?page=overview&session=".$sess."&lgn=1" );
        echo "<html><head><meta http-equiv='refresh' content='0;url=".hostname()."game/index.php?page=overview&session=".$sess."&lgn=1' /></head><body></body>";

        LogIPAddress ( $ip, $player_id );
    }
    else
    {
        header ( "Location: ".hostname()."game/reg/errorpage.php?errorcode=2&arg1=$uni&arg2=$login" );
        echo "<html><head><meta http-equiv='refresh' content='0;url=".hostname()."game/reg/errorpage.php?errorcode=2&arg1=$uni&arg2=$login' /></head><body></body>";
    }
    ob_end_flush ();
    exit ();
}

function hostname () {
    $host = "http://" . $_SERVER['HTTP_HOST'] . $_SERVER["SCRIPT_NAME"];
    $pos = strrpos ( $host, "/game/reg/login2.php" );
    return substr ( $host, 0, $pos+1 );
}

function to_utf8( $string ) { 
// From http://w3.org/International/questions/qa-forms-utf-8.html 
    if ( preg_match('%^(?: 
      [\x09\x0A\x0D\x20-\x7E]            # ASCII 
    | [\xC2-\xDF][\x80-\xBF]             # non-overlong 2-byte 
    | \xE0[\xA0-\xBF][\x80-\xBF]         # excluding overlongs 
    | [\xE1-\xEC\xEE\xEF][\x80-\xBF]{2}  # straight 3-byte 
    | \xED[\x80-\x9F][\x80-\xBF]         # excluding surrogates 
    | \xF0[\x90-\xBF][\x80-\xBF]{2}      # planes 1-3 
    | [\xF1-\xF3][\x80-\xBF]{3}          # planes 4-15 
    | \xF4[\x80-\x8F][\x80-\xBF]{2}      # plane 16 
)*$%xs', $string) ) { 
        return $string; 
    } else { 
        return iconv( 'CP1252', 'UTF-8', $string); 
    } 
} 

if ( $_SERVER['REQUEST_METHOD'] === "POST" ) Login ( $_POST['login'], $_POST['pass']);
else if ($_SERVER['REQUEST_METHOD'] === "GET") Login ( to_utf8 ($_GET['login']), to_utf8 ($_GET['pass']) );

echo "<html><head><meta http-equiv='refresh' content='0;url=$StartPage' /></head><body></body></html>";

?>
