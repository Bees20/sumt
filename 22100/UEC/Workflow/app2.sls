{% set dict = salt['pillar.get']('DICT') %}
{% set applications2 = 
'{
   "collabtools": {
      "template": "collabtools.template",
      "directory": "Package/collabtools",
      "servicefile": "/lib/systemd/system/collabtools.service",
      "destination": "/opt/suite/collabtools",
      "configs": {
         "appsettings": {
            "keys": {
               "Update_UDAC_port": {
                  "_pattern": "UDACAgentEndpoint",
                  "_spacing": "      ",
                  "_key": "UDACAgentEndpoint",
                  "_value": "http://localhost:'+ dict['UDAC_API_PORT'] +'",
                  "_ending": ""
               },
               "UpdateLogPath": {
                  "_pattern": "path",
                  "_spacing": "          ",
                  "_key": "path",
                  "_value": "'+ dict['LINUX_LOG_DIRECTORY'] +'collabtools-processor-.json",
                  "_ending": ","
               },
               "Update_openbadge_port": {
                  "_pattern": "Url",
                  "_spacing": "        ",
                  "_key": "Url",
                  "_value": "http://localhost:'+ dict['UEC_COLLABTOOLS_PORT'] +'",
                  "_ending": ""
               }
            },
            "_name": "appsettings,json",
            "_path": "collabtools/appsettings.json"
         }
      }
   }
}'
%}
{% set applications2 = applications2 | load_json %}