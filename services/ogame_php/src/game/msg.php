<?php

// Управление сообщениями.

// Запись сообщения в БД.
// msg_id: Порядковый номер сообщения (INT AUTO_INCREMENT PRIMARY KEY)
// owner_id: Порядковый номер пользователя которому принадлежит сообщение
// pm: Тип сообщения, 0: личное сообщение (можно пожаловаться оператору), ...
// msgfrom: От кого, HTML (TEXT)
// subj: Тема, HTML, может быть текст, может быть ссылка на доклад (TEXT)
// text: Текст сообщения (TEXT)
// shown: 0 - новое сообщение, 1 - показанное.
// date: Дата сообщения (INT UNSIGNED)

/*
Типы сообщений (pm):
0 - личное сообщение
1 - шпионский доклад
2 - ссылка на боевой доклад
3 - сообщение из экспедиции
4 - альянс
5 - прочие
6 - текст боевого доклада
*/

// Всего у пользователя может быть не более 127 сообщений. Если происходит переполнение, то самое старое сообщение удаляется и добавляется новое.
// Сообщение хранится 24 часа.

// В личных сообщениях можно использовать BB-коды:
// Простые: b u i s sub sup hr
// Цвет: [color=ЦВЕТ][/color], размер [size=РАЗМЕР][/size], шрифт [font=FONT][/font], цитата [quote=От кого][/quote]
// URL: [url=ПУТЬ][/url], Email: [email=EMAIL][/email], Картинка [img=путь][/img]
// Выравнивание: [align=left,right,center][/align]

// Если в "от кого", теме или тексте сообщения есть слово {PUBLIC_SESSION}, то при выводе оно заменяется на текущую сессию пользователя.

// У каждого пользователя есть лимит сообщений в сутки. Выводится ошибка "Вы сегодня написали слишком много".

// Удалить все старые сообщения (вызывается из меню Сообщения)
function DeleteExpiredMessages ($player_id)
{
    global $db_prefix;
    $now = time ();
    $hours24 = 60 * 60 * 24;

    // Не удалять сообщения администрации.
    $user = LoadUser ($player_id);
    if ($user['admin'] > 0 ) return;

    $query = "SELECT * FROM ".$db_prefix."messages WHERE owner_id = $player_id";
    $result = dbquery ($query);
    $num = dbrows ($result);
    while ($num--)
    {
        $msg = dbarray ($result);
        if ( ($msg['date'] + $hours24) <= $now ) DeleteMessage ($player_id, $msg['msg_id']);
    }
}

// Удалить самое старое сообщение (вызывается из SendMessage)
function DeleteOldestMessage ($player_id)
{
    global $db_prefix;
    $query = "SELECT * FROM ".$db_prefix."messages WHERE owner_id = $player_id ORDER BY date ASC";
    $result = dbquery ($query);
    $msg = dbarray ($result);
    DeleteMessage ( $player_id, $msg['msg_id']);
}




function sendTelegramMessage($chatID, $messaggio, $telegram_bot_token) {
    echo "sending message to " . $chatID . "\n";

    $url = "https://api.telegram.org/bot" . $telegram_bot_token . "/sendMessage?chat_id=" . $chatID;
    $url = $url . "&text=" . urlencode($messaggio);
    $ch = curl_init();
    $optArray = array(
            CURLOPT_URL => $url,
            CURLOPT_RETURNTRANSFER => true
    );
    curl_setopt_array($ch, $optArray);
    $result = curl_exec($ch);
    curl_close($ch);
    return $result;
}


// $users_telegram_array = [
//     "user_id": "100001", "chat_id": "451081795",
//     "user_id": "100000", "chat_id": "235258698",
// ];

// $files = array();
// $files['100001'] = "451081795";
// $files['100000'] = "235258698";




function wh_log($log_msg)
{
    $log_filename = "log";
    if (!file_exists($log_filename)) 
    {
        // create directory/folder uploads.
        mkdir($log_filename, 0777, true);
    }
    $log_file_data = $log_filename.'/log_' . date('d-M-Y') . '.log';
    // if you don't add `FILE_APPEND`, the file will be erased each time you add a log
    file_put_contents($log_file_data, $log_msg . "\n", FILE_APPEND);
} 

// Послать сообщение. Возвращает id нового сообщения. (может вызываться откуда угодно)
function SendMessage ($user, $player_id, $from, $subj, $text, $pm, $when=0)
{
    global $db_prefix;
    global $user;
    global $users_telegram_array;
    global $telegram_bot_token;
    $telegram_bot_token = "1497509259:AAFdKX47jNO3HZcARHDStrDFuKAgoMmivN4";
    $users_telegram_array=array("100001"=>"451081795","100000"=>"235258698");

    if ($when == 0) $when = time ();

    // Обработать параметры.
    if ($pm == 0) {
        $text = mb_substr ($text, 0, 2000, "UTF-8");
        //$text = bb ($text);
    }

    // Получить количество сообщений для пользователя.
    $query = "SELECT * FROM ".$db_prefix."messages WHERE owner_id = $player_id";
    $result = dbquery ($query);
    if ( dbrows ($result) >= 127 )    // Удалить самое старое сообщение и освободить место для нового.
    {
        DeleteOldestMessage ($player_id);
    }

    // Добавить сообщение.
    $msg = array( null, $player_id, $pm, $from, $subj, $text, 0, $when );
    $id = AddDBRow ( $msg, "messages" );

    $debug_msg = "BEFORE FOREACH USERS ARRAY\n message: $msg\n player_id: $player_id\n text: $text";
    // call to function
    wh_log($debug_msg);

    foreach($users_telegram_array as $x=>$x_value)
    {
        $debug_for_a_each_user_id = " 0z_id=" . $x . ",\n t_chat_id=" . $x_value . ",\n player_id=" . $player_id . "\n";
        wh_log($debug_for_a_each_user_id);

        if ( $x == $player_id ){

            $matched_values_message = " MATH!\n to_0z_id=" . $x .",\n to_player_id=" . $player_id . "\n";
            $text = bb ($text);
            $user_oname = $user['oname'];
            $subj_tripped = explode("<", $subj);
            $from_tripped = explode("<", $from);
            $text_tripped = explode("<", $text);
            $replace  = "\n";
            $search = '&lt;br /&gt;<br />';
            // ""
            $newstr_text = str_replace($search, $replace, $text);
            // echo "from_tripped: " . $from_tripped[0];
            //------- // ------- // ------- // -------
            //________________________________________
            // ****************************************
            // """"""""""""""""""""""""""""""""""""""""
            // ''''''''''''''''''''''''''''''''''''''''
            // ||||||||||||||||||||||||||||||||||||||||
            // /'''''''''''''''''''''''''''''''''''''''
            $telegram_message = " \n\n~# => || [incoming message] || ====================== \n     Сообщение для: $user_oname \n     Получено от: " . $from_tripped[0] . " \n     Тема: " . $subj_tripped[0] . "\n~# ========================================== \n     Сообщение: \n~# ------- // ------- // ------- // ------- // ------- // ------- |:| \n     " . $newstr_text . "\n~# ========================== || [end message] || <= \n";

            sendTelegramMessage($x_value, $telegram_message, $telegram_bot_token);
        }

    }

    foreach($database as $file) {
        echo $file['filename'] . ' at ' . $file['filepath'];
    }

    foreach($users_telegram_array as $element):
        wh_log("element: $element");
    #do something
    endforeach;
    
    foreach ($users_telegram_array as list($PLAYER_KEY, $TELEGRAM_CHAT_ID)) {
        // $a содержит первый элемент вложенного массива,
        // а $b содержит второй элемент.
        $debug_foreach = "PLAYER_KEY: $PLAYER_KEY;\n TELEGRAM_CHAT_ID: $TELEGRAM_CHAT_ID\n";
        wh_log($debug_foreach);

        echo "PLAYER_KEY: $PLAYER_KEY;\n TELEGRAM_CHAT_ID: $TELEGRAM_CHAT_ID\n";
        
        $message = "Message\n item: $item\n key: $key\n text: $text\n";
        $debug_msg2 = "in For Each\n item: $item\n player_id: $player_id\n key: $key\n message: $message\n";
        // call to function
        wh_log($debug_msg2);

        if ( $player_id == $item ){
            $user[] = $item;
            $chatid = $item;
            sendTelegramMessage($chatid, $msg, $token);
        }

    }

    // foreach ($users_telegram_array as $key => $item) {
        
        
       

    //     $debug_msg2 = "in For Each\n item: $item\n player_id: $player_id\n key: $key\n message: $message\n";
    //     // call to function
    //     wh_log($debug_msg2);

    //     Debug();
       
    //     echo "$item\n";

    //     if ( $player_id == $item ){
    //         $user[] = $item;
    //         $chatid = $item;
    //         sendTelegramMessage($chatid, $msg, $token);
    //     }

    // }
    // print_r($user);

    return $id;
}

// Удалить сообщение (вызывается из меню Сообщения)
function DeleteMessage ($player_id, $msg_id)
{
    global $db_prefix;
    $query = "DELETE FROM ".$db_prefix."messages WHERE owner_id = $player_id AND msg_id = $msg_id";
    dbquery ($query);
}

// Загрузить последние N сообщений (вызывается из меню Сообщения).
// Не загружать текст боевых докладов
function EnumMessages ($player_id, $max)
{
    global $db_prefix;
    $query = "SELECT * FROM ".$db_prefix."messages WHERE owner_id = $player_id AND pm <> 6 ORDER BY date DESC, msg_id DESC LIMIT $max";
    $result = dbquery ($query);
    return $result;
}

// Получить количество непрочитанных сообщений (вызывается из Обзора)
function UnreadMessages ($player_id)
{
    global $db_prefix;
    $query = "SELECT * FROM ".$db_prefix."messages WHERE owner_id = $player_id AND shown = 0";
    $result = dbquery ($query);
    return dbrows ($result);
}

// Пометить сообщение как прочтенное (вызывается из меню Сообщения).
function MarkMessage ($player_id, $msg_id)
{
    global $db_prefix;
    $query = "UPDATE ".$db_prefix."messages SET shown = 1 WHERE owner_id = $player_id AND msg_id = $msg_id";
    dbquery ($query);
}

// Загрузить сообщение.
function LoadMessage ( $msg_id )
{
    global $db_prefix;
    $query = "SELECT * FROM ".$db_prefix."messages WHERE msg_id = $msg_id";
    $result = dbquery ($query);
    if ( $result ) return dbarray ($result);
    else return NULL;
}

// Удалить все сообщения
function DeleteAllMessages ($player_id)
{
    global $db_prefix;
    $query = "DELETE FROM ".$db_prefix."messages WHERE owner_id = $player_id";
    dbquery ($query);
}

?>
