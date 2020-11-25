<html>
<head>
<link rel="stylesheet" type="text/css" href="http://graphics.ogame-cluster.net/download/use/evolutionformate.css">
<link rel="stylesheet" type="text/css" href="/game/css/registration.css" />
<meta http-equiv="content-type" content="text/html; charset=UTF-8" />
<script language="JavaScript" src="/game/js/tw-sack.js"></script>
<script language="JavaScript" src="/game/js/registration.js"></script>
<script language="JavaScript">
function printMessage(code, div) {
    var textclass = "";

    if (div == null) {
        div = "statustext";
    }
    switch (code) {
        case "0":
            text = "OK";
            textclass = "fine";
            break;
        case "101":
            text = "����� ��� ��� ����������!";
            textclass = "warning";
            break;
        case "102":
            text = "���� ����� ��� ������������!";
            textclass = "warning";
            break;
        case "103":
            text = "��� ������ ��������� �� 3 �� 20 ��������!";
            textclass = "warning";
            break;
        case "104":
            text = "����� ��������������!";
            textclass = "warning";
            break;
        case "105":
            text = "��� ������ - � �������";
            textclass = "fine";
            break;
        case "106":
            text = "����� - � �������";
            textclass = "fine";
            break;
        case "107":
            text = "����� ��������������!";
            textclass = "warning";
            break;
        case "201":
            text = "��� � ����: <br />��� ��� ������ ��������� � ����. � ����� ��������� �� ����� ���� ���� ���������� ���.";
            break;
        case "202":
            text = "����������� �����: <br />�� ���� ����� ����� ������ ��� ������. ���� �� ������ ����� ��� ��������������� �����, �� ������  ��, ��������������, �� �������.";
            break;
        case "203":
            text = "";
            break;
        case "204":
            text = "��� ����, ����� ������ ���� �� ������ ����������� � ��������� �����������.";
            break;
        default:
            return;
            break;
    }

    if (textclass != "") {
        text = "<span class='" + textclass + "'>" + text + "</span>";
    }
    document.getElementById(div).innerHTML = text;
}
</script>
</head>
<body>
<div id="overDiv" style="position:absolute; visibility:hidden; z-index:1000;"></div>
<center>
<h1 style="font-size: 22;">����� ��������� 5 �����������</h1>

<form id="registration" method="POST">
<table width="700">
 <tr>
  <td>
   <table width="380">
    <tr>
     <td class="c" colspan="2">������ �� ������</td>
    </tr>
    <tr>

     <th class="">��� � ����</th><th><input name="character" size="20"  value="" onfocus="javascript:showInfo('201');javascript:pollUsername();" onblur="javascript:stopPollingUsername();" /></th>
    </tr>
    <tr>
     <th class="">����������� �����</th><th><input name="email" size="20" value="" onfocus="javascript:showInfo('202');javascript:pollEmail();" onblur="javascript:stopPollingEmail();" /></th>
    </tr>
     <th class="">� ���������� � <a href='http://agb.gameforge.de/index.php?lang=ru&art=tac&special=&&f_text=b1daf2&f_text_hover=ffffff&f_text_h=061229&f_text_hr=061229&f_text_hrbg=061229&f_text_hrborder=9EBDE4&f_text_font=arial%2C+arial%2C+arial%2C+sans-serif&f_bg=000000' target='_blank'>��������� �����������</a></th><th><input type="checkbox" name="agb" onfocus="javascript:showInfo('204');"/></th>
    </tr>

        <tr>
     <th colspan="2" style="text-align: center;"><input type="submit" value="������������������" /></th>
          <input type="hidden" name="v" value="3" /><input type="hidden" name="step" value="validate" />
          <input type="hidden" name="try" value="2" />
          <input type="hidden" name="kid" value="" />
     </tr>
   </table>
  </td>
  <td>

   <table width="320">
    <tr>
     <td class="c">����</td>
    </tr>
    <tr style="height: 93;">
     <th><p /><div id="infotext"></div><p /><div id="statustext"></div><div id="debug"></div> </th>
    </tr>
   </table>

  </td>
 </tr>
</table>
</form>
</center>
</body>
</html>
