DROP PROCEDURE IF EXISTS RefreshData;

DELIMITER $$

CREATE
    /*[DEFINER = { user | CURRENT_USER }]*/
    PROCEDURE `RefreshData`(p_prodSiteKey VARCHAR(100), p_stageSiteKey VARCHAR(100))
    /*LANGUAGE SQL
    | [NOT] DETERMINISTIC
    | { CONTAINS SQL | NO SQL | READS SQL DATA | MODIFIES SQL DATA }
    | SQL SECURITY { DEFINER | INVOKER }
    | COMMENT 'string'*/
              BEGIN

              DECLARE prodSiteKey VARCHAR(100);
              DECLARE stageSiteKey VARCHAR(100);
              
              SET prodSiteKey =  p_prodSiteKey;
              SET stageSitekey =  p_stageSiteKey;
              
              UPDATE ScormObjectIdentifiers SET item_identifier = REPLACE (item_identifier, prodSiteKey, stageSitekey),resource_identifier= REPLACE (resource_identifier, prodSiteKey, stageSitekey) ,external_identifier= REPLACE (external_identifier, prodSiteKey, stageSitekey);
              UPDATE ScormPackage SET web_path = REPLACE (web_path, prodSiteKey, stageSitekey);
              UPDATE SystemSimpleQueue SET queue_entry = REPLACE (queue_entry, prodSiteKey, stageSitekey);
              UPDATE TenantProperties SET property_value = REPLACE (property_value, prodSiteKey, stageSitekey);
              UPDATE TinCanContentToken SET external_configuration = REPLACE (external_configuration, prodSiteKey, stageSitekey);
              UPDATE TinCanDocuments SET activity_id = REPLACE (activity_id, prodSiteKey, stageSitekey),asserter_json = REPLACE (asserter_json, prodSiteKey, stageSitekey);
              UPDATE TinCanLaunchToken SET external_configuration = REPLACE (external_configuration, prodSiteKey, stageSitekey);
              UPDATE TinCanObjectStore SET object_value = REPLACE (object_value, prodSiteKey, stageSitekey);
              UPDATE TinCanPackage SET tincan_activity_id = REPLACE (tincan_activity_id, prodSiteKey, stageSitekey);

              END$$

DELIMITER ;
CALL RefreshData('{{Prod_URL}}', '{{Stage_URL}}');
CALL RefreshData('{{Prod_Site_key}}', '{{Stage_Site_Key}}');
