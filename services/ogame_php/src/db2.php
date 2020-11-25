<?php

function dbconnect ($db_host, $db_user, $db_pass, $db_name)
{
    $db_connect = @mysqli_connect($db_host, $db_user, $db_pass, $db_name);
    
    /* проверка соединения */
    if (mysqli_connect_errno()) {
        printf("Соединение не удалось: %s\n", mysqli_connect_error());
        exit();
    }   
    mysqli_query($db_connect, 'set names cp1251');
    if (!$db_connect) {
        die("<div style='font-family:Verdana;font-size:11px;text-align:center;'><b>Unable to establish connection to MySQL</b><br>".mysqli_error()." : ".mysqli_error()."</div>");
    } elseif (!$db_connect) {
        die("<div style='font-family:Verdana;font-size:11px;text-align:center;'><b>Unable to select MySQL database</b><br>".mysqli_error()." : ".mysqli_error()."</div>");
    }
}

function dbquery ($query, $mute=FALSE)
{
    global  $query_counter, $query_log;
    $query_counter ++;
    $query_log .= $query . "<br>\n";
    $result = @mysqli_query($query);
    if (!$result && $mute==FALSE) {
        echo "$query <br>";
        #echo mysqli_error();
        #Debug ( mysqli_error() . "<br>" . $query . "<br>" . BackTrace () ) ;
        return false;
    }
    else  
        return $result;
}

function dbrows ($query)
{
    $result = @mysqli_num_rows($query);
    return $result;
}

function dbarray ($query)
{
    $result = @mysqli_fetch_assoc($query);
    if (!$result) {
        echo mysqli_error();
        return false;
    }
    else return $result;
}

function dbfree ($result) {
    @mysql_freeresult($result);
}

