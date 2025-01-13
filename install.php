<?php
function extension_install_browseractivity()
{
    $commonObject = new ExtensionCommon;

    $commonObject -> sqlQuery(
        "CREATE TABLE IF NOT EXISTS `browseractivity` (
        `ID` INTEGER NOT NULL AUTO_INCREMENT, 
        `HARDWARE_ID` INTEGER NOT NULL,
        `DOMAIN` VARCHAR(255) DEFAULT NULL,   # https://stackoverflow.com/questions/14402407/maximum-length-of-a-domain-name-without-the-http-www-com-parts
        `TITLE` VARCHAR(255) DEFAULT NULL,    # has no limit, best practice is 60
        `PROTOCOL` VARCHAR(8) DEFAULT NULL,
        `USERNAME` VARCHAR(128) DEFAULT NULL, # https://stackoverflow.com/questions/704891/windows-username-maximum-length
        `VISITTIME` BIGINT NOT NULL,
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
