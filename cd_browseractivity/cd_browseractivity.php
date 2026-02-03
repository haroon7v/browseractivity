<?php
if (AJAX) {
    parse_str($protectedPost['ocs']['0'], $params);
    $protectedPost += $params;
    ob_start();
    $ajax = true;
} else {
    $ajax = false;
}

// print a title for the table
print_item_header("Browser Activity");

if (!isset($protectedPost['SHOW'])) {
    $protectedPost['SHOW'] = 'NOSHOW';
}

// form details and tab options
$form_name = "browseractivity";
$table_name = $form_name;
$tab_options = $protectedPost;
$tab_options['form_name'] = $form_name;
$tab_options['table_name'] = $table_name;


echo open_form($form_name);
$list_fields = array(
                    'Url' => 'URL',
                    'Domain' => 'DOMAIN',
                    'Title' => 'TITLE',
                    'Protocol' => 'PROTOCOL',
                    'Browser' => 'BROWSER',
                    // 'Username' => 'USERNAME',
                    // 'Visit Time' => 'VISITTIME',
                    'Accessed At' => 'ACCESSED_AT',
                    'Duration' => 'DURATION');
// columns to include at any time and default columns
$list_col_cant_del = $list_fields;
$default_fields = $list_fields;

// select columns for table display
$sql = prepare_sql_tab($list_fields);
$sql['SQL']  .= "FROM browseractivity WHERE (hardware_id = $systemid)";

array_push($sql['ARG'], $systemid);
$tab_options['ARG_SQL'] = $sql['ARG'];
$tab_options['ARG_SQL_COUNT'] = $systemid;
ajaxtab_entete_fixe($list_fields, $default_fields, $tab_options, $list_col_cant_del);

echo close_form();


if ($ajax) {
    ob_end_clean();
    tab_req($list_fields, $default_fields, $list_col_cant_del, $sql['SQL'], $tab_options);
    ob_start();
}
?>
