<script>
var ServerClientDifference = ({Now} * 1000) - new Date().getTime();
var AllowPrettyInputBox = {P_AllowPrettyInputBox};
var ResSortArrayAll = {ResSortArrayAll};
var ResSortArrayNoDeu = {ResSortArrayNoDeu};
var NeedQuantumGate = '{P_UserHave2UseQuantumGate}';
var FlightDuration = {P_FlightDuration};
var JSLang = {'fl2_FlyTimeInfo': '{fl2_FlyTimeInfo}', 'fl_coordplanet': '{fl_coordplanet}', 'fl_coordmoon': '{fl_coordplanet}', 'fl_coorddebris': '{fl_coorddebris}', 'confirm_allypact_attack': '{fl2_confirm_allypact_attack}'};
var SetResources = {SelectResources};
var SelectQuantumGate = {SelectQuantumGate};
var AllyPact_AttackWarn = {Insert_AllyPact_AttackWarn};
{QuantumGateJSArray}
{CreateTestACCAlert}
</script>
<script src="dist/js/fleet2.cachebuster-1546740741336.min.js"></script>
<link rel="stylesheet" type="text/css" href="dist/css/fleet2.cachebuster-1546565145290.min.css" />

<form id="thisForm" action="fleet3.php" method="post">
    <input type="hidden" name="sending_fleet"  value="1" />
    <input type="hidden" id="quickres" name="useQuickRes" value="{P_SetQuickRes}" />
    <input type="hidden" id="PlanetResource1"  value="{This_metal}"/>
    <input type="hidden" id="PlanetResource2"  value="{This_crystal}" />
    <input type="hidden" id="PlanetResource3"  value="{This_deuterium}" />
    <input type="hidden" id="Consumption"      value="{consumption}" />
    <input type="hidden" id="TotalStorage"     value="{totalstorage}"/>
    <input type="hidden" id="FreeStorage"      value="{freeStorage}"/>
    <input type="hidden" id="FuelStorage"      value="{FuelStorage}"/>
    <input type="hidden" id="FuelStorageReduceH" value="{FuelStorageReduceH}"/>
    <input type="hidden" id="FuelStorageReduce" value="{FuelStorageReduce}"/>
    <input type="hidden" name="galaxy"         value="{Target_galaxy}" />
    <input type="hidden" name="system"         value="{Target_system}" />
    <input type="hidden" name="planet"         value="{Target_planet}" />
    <input type="hidden" name="planettype"     value="{Target_type}" />
    <input type="hidden" name="speed"          value="{SetSpeed}" />
    <input type="hidden" name="FleetArray"     value="{FleetArray}"/>

    <br />
    {P_SFBInfobox}
    <table width="750" id="gTb">
        <tr>
            <td class="c" colspan="2">{fl2_title}{TitlePos}</td>
        </tr>
        <tr valign="top">
            <th width="300">
                <table width="100%" align="center">
                    <tr>
                        <td class="c" colspan="2">{fl_mission}</td>
                    </tr>
                    {MissionSelectors}
                    <tr{P_HideNoMissionInfo}>
                        <th>
                            <b class="red">{fl_bad_mission}</b>
                        </th>
                    </tr>
                    <tbody{P_HideQuantumGate}>
                        <tr>
                            <td class="c" colspan="2">{QuantumGateHead}</td>
                        </tr>
                        <tr>
                            <th class="QuantumInfo">
                                <input id="usequantumgate" type="checkbox" name="usequantumgate"/>
                                <label for="usequantumgate" class="mTxt">{QuantumGateUse}</label>
                                <br/><br />
                                <span class="lime {P_HideQuantumGateReady2Use}">{GateReadyToUse}</span>
                                {InsertQuantumGateChronoApplet}
                                <span class="orange {P_HideQuantumGateReady2UseIn}">{GateReadyToUseIn}:</span><br/><span id="bxxquantum0">{P_QuantumGateNextUse}</span>
                            </th>
                        </tr>
                    </tbody>
                </table>
            </th>
            <th width="450">
                <table width="100%">
                    <tr>
                        <td colspan="3" class="c">{fl_ressources}</td>
                    </tr>
                    <tr>
                        <th width="90">{Metal}</th>
                        <th width="90">
                            <a id="setMax1" class="pointer">{fl_selmax}</a> / <a id="setZero1" class="pointer">{fl_selnone}</a>
                        </th>
                        <th width="220">
                            <input class="resInput pad2" name="resource1" type="text" value="0" />
                        </th>
                    </tr>
                    <tr>
                        <th>{Crystal}</th>
                        <th>
                            <a id="setMax2" class="pointer">{fl_selmax}</a> / <a id="setZero2" class="pointer">{fl_selnone}</a>
                        </th>
                        <th>
                            <input class="resInput pad2" name="resource2" type="text" value="0" />
                        </th>
                    </tr>
                    <tr>
                        <th>{Deuterium}</th>
                        <th>
                            <a id="setMax3" class="pointer">{fl_selmax}</a> / <a id="setZero3" class="pointer">{fl_selnone}</a>
                        </th>
                        <th>
                            <input class="resInput pad2" name="resource3" type="text" value="0" />
                        </th>
                    </tr>
                    <tr class="inv">
                        <td></td>
                    </tr>
                    <tr>
                        <th>{fl_max_load}</th>
                        <th colspan="2">
                            <b id="FreeStorageShow" class="{SetDefaultFreeStorageColor}">{SetDefaultFreeStorage}</b>
                        </th>
                    </tr>
                    <tr class="inv">
                        <td></td>
                    </tr>
                    <tr>
                        <th colspan="3">
                            <a id="setMaxAll" class="pointer">{fl_allressources}</a> / <a id="setZeroAll" class="pointer">{fl2_allResZero}</a>
                        </th>
                    </tr>

                    <tbody{P_HideExpeditionTimers}>
                        <tr>
                            <td class="c" colspan="3">{fl_expe_staytime}</td>
                        </tr>
                        <tr>
                            <th colspan="3">
                                <select name="expeditiontime">
                                    <option value="1" {SelectExpedition_1}>1</option>
                                    <option value="2" {SelectExpedition_2}>2</option>
                                    <option value="3" {SelectExpedition_3}>3</option>
                                    <option value="4" {SelectExpedition_4}>4</option>
                                    <option value="5" {SelectExpedition_5}>5</option>
                                    <option value="6" {SelectExpedition_6}>6</option>
                                    <option value="7" {SelectExpedition_7}>7</option>
                                    <option value="8" {SelectExpedition_8}>8</option>
                                    <option value="9" {SelectExpedition_9}>9</option>
                                    <option value="10" {SelectExpedition_10}>10</option>
                                    <option value="11" {SelectExpedition_11}>11</option>
                                    <option value="12" {SelectExpedition_12}>12</option>
                                </select>
                                {fl_expe_hours}
                            </th>
                        </tr>
                    </tbody>

                    <tbody{P_HideHoldingTimers}>
                           <tr>
                            <td class="c" colspan="3">{fl_expe_staytime}</td>
                        </tr>
                        <tr>
                            <th colspan="3">
                            <select name="holdingtime">
                                <option value="1" {SelectHolding_1}>1</option>
                                <option value="2" {SelectHolding_2}>2</option>
                                <option value="4" {SelectHolding_4}>4</option>
                                <option value="8" {SelectHolding_8}>8</option>
                                <option value="16" {SelectHolding_16}>16</option>
                                <option value="32" {SelectHolding_32}>32</option>
                            </select>
                            {fl_expe_hours}
                            </th>
                        </tr>
                    </tbody>

                    <tbody{P_HideACSJoinList}>
                        <tr>
                            <td class="c" colspan="3">{fl_select_acs}</td>
                        </tr>
                        <tr>
                            <th colspan="3">
                            <select name="acs_id">
                                {CreateACSList}
                            </select>
                            </th>
                        </tr>
                    </tbody>

                </table>
            </th>
        </tr>
        <tr>
            <th colspan="2">
                <table width="100%" align="center" id="InfoTable">
                    <tr>
                        <th class="flyTimeNoInfo">{fl2_flightTime}</th>
                        <th class="flyTimeInfo">{fl2_flightTime}</th>
                        <th><b id="FlightTimeShow">{FlightTimeShow}</b> h</th>
                        <th class="inv"></th>
                        <th>{fl2_destination}</th>
                        <th>{ShowTargetPos}</th>
                    </tr>
                    <tr>
                        <th>{fl_reachtime}</th>
                        <th id="ReachTime">-</th>
                        <th class="inv"></th>
                        <th>{fl2_targetowner}</th>
                        <th>{ShowTargetOwner}</th>
                    </tr>
                    <tr>
                        <th>{fl_comebacktime}</th>
                        <th id="BackTime">-</th>
                        <th class="inv"></th>
                        <th>{fl_deute_need}</th>
                        <th id="FuelUse">{ShowConsumption}</th>
                    </tr>
                </table>
            </th>
        </tr>
        <tr id="noDeutInfo">
            <th colspan="2" class="red">{fl2_Have2UseQuantumGate}</th>
        </tr>
        <tr>
            <th colspan="2">
                <input class="SendButtom orange" type="button" value="&laquo; {fl_goback}" id="goBack"/>
                <input class="SendButtom lime" type="submit" value="{fl2_SendButton} &raquo;"/>
            </th>
        </tr>
    </table>
</form>
