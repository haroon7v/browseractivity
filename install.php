<?php
function extension_install_chromeactivity()
{
    $commonObject = new ExtensionCommon;

    $commonObject -> sqlQuery(
        "CREATE TABLE IF NOT EXISTS `chromeactivity` (
        `ID` INTEGER NOT NULL AUTO_INCREMENT, 
        `HARDWARE_ID` INTEGER NOT NULL,
        `URL` VARCHAR(255) DEFAULT NULL,
        `DOMAIN` VARCHAR(255) DEFAULT NULL,
        `SUBDOMAIN` VARCHAR(255) DEFAULT NULL,
        `PROTOCOL` VARCHAR(255) DEFAULT NULL,
        `USERNAME` VARCHAR(255) DEFAULT NULL,
        `ACCESSEDAT` DATETIME DEFAULT NULL,
        PRIMARY KEY (ID,HARDWARE_ID)) ENGINE=INNODB;"
    );
}

function extension_delete_chromeactivity()
{
    $commonObject = new ExtensionCommon;
    $commonObject -> sqlQuery("DROP TABLE IF EXISTS `chromeactivity`");
}

function extension_upgrade_chromeactivity()
{

}

?>
