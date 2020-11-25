<?php

// TODO: Migrate to IIFE once PHP 5 support is removed
call_user_func(function () {
    global $_EnginePath;

    $includePath = $_EnginePath . 'modules/development/';

    include($includePath . './utils/queue.utils.php');
    include($includePath . './utils/research.utils.php');
    include($includePath . './utils/structures.utils.php');

    include($includePath . './input/research.userCommands.php');
    include($includePath . './input/structures.userCommands.php');

    include($includePath . './components/ModernQueue/ModernQueue.component.php');
    include($includePath . './components/LegacyQueue/LegacyQueue.component.php');
    include($includePath . './components/ListViewElementRow/ListViewElementRow.component.php');
    include($includePath . './components/ListViewElementRow/UpgradeProductionChange/UpgradeProductionChange.component.php');
    include($includePath . './components/ListViewElementRow/UpgradeResourcesCost/UpgradeResourcesCost.component.php');
    include($includePath . './components/ListViewElementRow/UpgradeResourcesRest/UpgradeResourcesRest.component.php');
    include($includePath . './components/GridViewElementIcon/GridViewElementIcon.component.php');
    include($includePath . './components/GridViewElementCard/GridViewElementCard.component.php');
    include($includePath . './components/GridViewElementCard/UpgradeRequirements/UpgradeRequirements.component.php');
    include($includePath . './components/GridViewElementCard/UpgradeRequirements/ResourcesList/ResourcesList.component.php');
    include($includePath . './components/GridViewElementCard/UpgradeProductionChange/UpgradeProductionChange.component.php');

    include($includePath . './screens/StructuresView/StructuresView.component.php');
    include($includePath . './screens/StructuresView/components/GridView/GridView.component.php');
    include($includePath . './screens/StructuresView/components/ListView/ListView.component.php');

    include($includePath . './screens/ResearchView/ResearchView.component.php');
    include($includePath . './screens/ResearchView/components/GridView/GridView.component.php');
    include($includePath . './screens/ResearchView/components/ListView/ListView.component.php');

    include($includePath . './screens/ResearchListPage/ModernQueuePlanetInfo/ModernQueuePlanetInfo.component.php');
    include($includePath . './screens/ResearchListPage/ModernQueueLabUpgradeInfo/ModernQueueLabUpgradeInfo.component.php');

});

?>
