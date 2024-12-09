<?php
function extension_install_browseractivity()
{
    $commonObject = new ExtensionCommon;

    $commonObject -> sqlQuery(
        "CREATE TABLE IF NOT EXISTS `browseractivity` (
        `ID` INTEGER NOT NULL AUTO_INCREMENT, 
        `HARDWARE_ID` INTEGER NOT NULL,
        `DOMAIN` VARCHAR(255) DEFAULT NULL,
        `TITLE` VARCHAR(255) DEFAULT NULL,
        `PROTOCOL` VARCHAR(8) DEFAULT NULL,
        `USERNAME` VARCHAR(255) DEFAULT NULL,
        `ACCESSEDAT` DATETIME DEFAULT NULL,
        PRIMARY KEY (ID,HARDWARE_ID)) ENGINE=INNODB;"
    );
}

function extension_delete_browseractivity()
{
    $commonObject = new ExtensionCommon;
    $commonObject -> sqlQuery("DROP TABLE IF EXISTS `browseractivity`");
}

function extension_upgrade_browseractivity()
{

}

?>
