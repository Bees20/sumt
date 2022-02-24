{% set dict = salt['pillar.get']('DICT') %}
{% set applications = 
'{
   "webhooks": {
      "template": "webhooks.template",
      "directory": "Package/webhooks",
      "servicefile": "/lib/systemd/system/webhooks.service",
      "destination": "/opt/suite/webhooks",
      "configs": {
         "appsettings": {
            "keys": {
               "BrokerNodes": {
                  "_pattern": "BrokerNodes",
                  "_spacing": "    ",
                  "_key": "BrokerNodes",
                  "_value": "'+ dict['UKA_SERVER_NODES'] +'",
                  "_ending": ","
               },
               "SchemaRegistryNodes": {
                  "_pattern": "SchemaRegistryNodes",
                  "_spacing": "    ",
                  "_key": "SchemaRegistryNodes",
                  "_value": "'+ dict['UKA_SERVER_NODES'] | replace("9092","8081") +'",
                  "_ending": ","
               },
               "Update_UDAC_port": {
                  "_pattern": "UDACAgentEndpoint",
                  "_spacing": "            ",
                  "_key": "UDACAgentEndpoint",
                  "_value": "http://localhost:'+ dict['UDAC_API_PORT'] +'",
                  "_ending": ""
               },
               "UpdateLogPath": {
                  "_pattern": "pathFormat",
                  "_spacing": "                    ",
                  "_key": "pathFormat",
                  "_value": "'+ dict['LINUX_LOG_DIRECTORY'] +'webhooks-{Date}.json",
                  "_ending": ","
               },
               "Update_webhooks_port": {
                  "_pattern": "Url",
                  "_spacing": "                ",
                  "_key": "Url",
                  "_value": "http://localhost:'+ dict['UEC_WEBHOOKS_PORT'] +'",
                  "_ending": ""
               }
            },
            "_name": "appsettings.json",
            "_path": "webhooks/appsettings.json"
         }
      }
   },
   "usersummary": {
      "template": "usersummary.template",
      "directory": "Package/usersummary",
      "servicefile": "/lib/systemd/system/usersummary.service",
      "destination": "/opt/suite/usersummary",
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
                  "_value": "'+ dict['LINUX_LOG_DIRECTORY'] +'usersummaryprocessor.json",
                  "_ending": ","
               },
               "Update_usersummary_port": {
                  "_pattern": "Url",
                  "_spacing": "        ",
                  "_key": "Url",
                  "_value": "http://localhost:'+ dict['UEC_USERSUMMARY_PORT'] +'",
                  "_ending": ""
               }
            },
            "_name": "appsettings.json",
            "_path": "usersummary/appsettings.json"
         }
      }
   },
   "useractionhistory": {
      "template": "useractionhistory.template",
      "directory": "Package/useractionhistory",
      "servicefile": "/lib/systemd/system/useractionhistory.service",
      "destination": "/opt/suite/useractionhistory",
      "configs": {
         "appsettings": {
            "keys": {
               "BrokerNodes": {
                  "_pattern": "BrokerNodes",
                  "_spacing": "    ",
                  "_key": "BrokerNodes",
                  "_value": "'+ dict['UKA_SERVER_NODES'] +'",
                  "_ending": ","
               },
               "Update_UDAC_port": {
                  "_pattern": "UDACAgentEndpoint",
                  "_spacing": "      ",
                  "_key": "UDACAgentEndpoint",
                  "_value": "http://localhost:'+ dict['UDAC_API_PORT'] +'",
                  "_ending": ""
               },
               "UpdateLogPath": {
                  "_pattern": "pathFormat",
                  "_spacing": "          ",
                  "_key": "pathFormat",
                  "_value": "'+ dict['LINUX_LOG_DIRECTORY'] +'useractionhistory-proc-{Date}.json",
                  "_ending": ","
               }
            },
            "_name": "appsettings.json",
            "_path": "useractionhistory/appsettings.json"
         }
      }
   },
   "registrationsupdate": {
      "template": "registrationsupdate.template",
      "directory": "Package/registrationsupdate",
      "servicefile": "/lib/systemd/system/registrationsupdate.service",
      "destination": "/opt/suite/registrationsupdate",
      "configs": {
         "appsettings": {
            "keys": {
               "Update_UDAC_port": {
                  "_pattern": "UDACAgentEndpoint",
                  "_spacing": "      ",
                  "_key": "UDACAgentEndpoint",
                  "_value": "http://localhost:'+ dict['UDAC_API_PORT'] +'",
                  "_ending": ""
               }
            },
            "_name": "appsettings.json",
            "_path": "registrationsupdate/appsettings.json"
         },
         "logging": {
            "keys": {
               "UpdateLogPath": {
                  "_pattern": "path",
                  "_spacing": "          ",
                  "_key": "path",
                  "_value": "'+ dict['LINUX_LOG_DIRECTORY'] +'registrationsupdate-.json",
                  "_ending": ","
               }
            },
            "_name": "logging.json",
            "_path": "registrationsupdate/Configs/logging.json"
         },
         "hosting": {
            "keys": {
               "update_registrationsupdate_port": {
                  "_pattern": "urls",
                  "_spacing": "  ",
                  "_key": "urls",
                  "_value": "http://localhost:'+ dict['UEC_REGISTRATIONUPDATE_PORT'] +';",
                  "_ending": ""
               }
            },
            "_name": "hosting.json",
            "_path": "registrationsupdate/Configs/hosting.json"
         }
      }
   },
   "registrationsdelete": {
      "template": "registrationsdelete.template",
      "directory": "Package/registrationsdelete",
      "servicefile": "/lib/systemd/system/registrationsdelete.service",
      "destination": "/opt/suite/registrationsdelete",
      "configs": {
         "appsettings": {
            "keys": {
               "Update_UDAC_port": {
                  "_pattern": "UDACAgentEndpoint",
                  "_spacing": "      ",
                  "_key": "UDACAgentEndpoint",
                  "_value": "http://localhost:'+ dict['UDAC_API_PORT'] +'",
                  "_ending": ""
               }
            },
            "_name": "appsettings.json",
            "_path": "registrationsdelete/appsettings.json"
         },
         "logging": {
            "keys": {
               "UpdateLogPath": {
                  "_pattern": "path",
                  "_spacing": "          ",
                  "_key": "path",
                  "_value": "'+ dict['LINUX_LOG_DIRECTORY'] +'registrationsdelete-.json",
                  "_ending": ","
               }
            },
            "_name": "logging.json",
            "_path": "registrationsdelete/Configs/logging.json"
         },
         "hosting": {
            "keys": {
               "update_registrationsdelete_port": {
                  "_pattern": "urls",
                  "_spacing": "  ",
                  "_key": "urls",
                  "_value": "http://localhost:'+ dict['UEC_REGISTRATIONDELETE_PORT'] +';",
                  "_ending": ""
               }
            },
            "_name": "hosting.json",
            "_path": "registrationsdelete/Configs/hosting.json"
         }
      }
   },
   "openbadges": {
      "template": "openbadges.template",
      "directory": "Package/openbadges",
      "servicefile": "/lib/systemd/system/openbadges.service",
      "destination": "/opt/suite/openbadges",
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
                  "_pattern": "pathFormat",
                  "_spacing": "          ",
                  "_key": "pathFormat",
                  "_value": "'+ dict['LINUX_LOG_DIRECTORY'] +'openbadges-processor-{Date}.json",
                  "_ending": ","
               },
               "Update_openbadges_port": {
                  "_pattern": "Url",
                  "_spacing": "        ",
                  "_key": "Url",
                  "_value": "http://localhost:'+ dict['UEC_OPENBADGE_PORT'] +'",
                  "_ending": ""
               }
            },
            "_name": "appsettings.json",
            "_path": "openbadges/appsettings.json"
         }
      }
   },
   "notificationprocessor": {
      "template": "notificationprocessor.template",
      "directory": "Package/notificationprocessor",
      "servicefile": "/lib/systemd/system/notificationprocessor.service",
      "destination": "/opt/suite/notificationprocessor",
      "configs": {
         "appsettings": {
            "keys": {
               "BrokerNodes": {
                  "_pattern": "BrokerNodes",
                  "_spacing": "    ",
                  "_key": "BrokerNodes",
                  "_value": "'+ dict['UKA_SERVER_NODES'] +'",
                  "_ending": ","
               },
               "SchemaRegistryNodes": {
                  "_pattern": "SchemaRegistryNodes",
                  "_spacing": "    ",
                  "_key": "SchemaRegistryNodes",
                  "_value": "'+ dict['UKA_SERVER_NODES'] | replace("9092","8081") +'",
                  "_ending": ","
               },
               "Update_UDAC_port": {
                  "_pattern": "UDACAgentEndpoint",
                  "_spacing": "      ",
                  "_key": "UDACAgentEndpoint",
                  "_value": "http://localhost:'+ dict['UDAC_API_PORT'] +'",
                  "_ending": ""
               },
               "UpdateLogPath": {
                  "_pattern": "pathFormat",
                  "_spacing": "          ",
                  "_key": "pathFormat",
                  "_value": "'+ dict['LINUX_LOG_DIRECTORY'] +'notificationprocessor-{Date}.json",
                  "_ending": ","
               },
               "Update_notificationprocessor_port": {
                  "_pattern": "Url",
                  "_spacing": "        ",
                  "_key": "Url",
                  "_value": "http://localhost:'+ dict['UEC_NOTIFICATIONPROCESSOR_PORT'] +'",
                  "_ending": ""
               }
            },
            "_name": "appsettings.json",
            "_path": "notificationprocessor/appsettings.json"
         }
      }
   },
   "eventgenerator": {
      "template": "eventgenerator.template",
      "directory": "Package/eventgenerator",
      "servicefile": "/lib/systemd/system/eventgenerator.service",
      "destination": "/opt/suite/eventgenerator",
      "configs": {
         "appsettings": {
            "keys": {
               "Update_UDAC_port": {
                  "_pattern": "UDACAgentEndpoint",
                  "_spacing": "            ",
                  "_key": "UDACAgentEndpoint",
                  "_value": "http://localhost:'+ dict['UDAC_API_PORT'] +'",
                  "_ending": ""
               }
            },
            "_name": "appsettings.json",
            "_path": "eventgenerator/appsettings.json"
         },
         "logging": {
            "keys": {
               "UpdateLogPath": {
                  "_pattern": "path",
                  "_spacing": "          ",
                  "_key": "path",
                  "_value": "'+ dict['LINUX_LOG_DIRECTORY'] +'eventgenerator-.json",
                  "_ending": ","
               }
            },
            "_name": "logging.json",
            "_path": "eventgenerator/logging.json"
         },
         "hosting": {
            "keys": {
               "update_eventgenerator_port": {
                  "_pattern": "urls",
                  "_spacing": "  ",
                  "_key": "urls",
                  "_value": "http://localhost:'+ dict['UEC_EVENTGENERATOR_PORT'] +';",
                  "_ending": ""
               }
            },
            "_name": "hosting.json",
            "_path": "eventgenerator/hosting.json"
         }
      }
   },
   "contentmanagement": {
      "template": "contentmanagement.template",
      "directory": "Package/contentmanagement",
      "servicefile": "/lib/systemd/system/contentmanagement.service",
      "destination": "/opt/suite/contentmanagement",
      "configs": {
         "appsettings": {
            "keys": {
               "Update_UDAC_port": {
                  "_pattern": "UDACAgentEndpoint",
                  "_spacing": "      ",
                  "_key": "UDACAgentEndpoint",
                  "_value": "http://localhost:'+ dict['UDAC_API_PORT'] +'",
                  "_ending": ""
               }
            },
            "_name": "appsettings.json",
            "_path": "contentmanagement/appsettings.json"
         },
         "logging": {
            "keys": {
               "UpdateLogPath": {
                  "_pattern": "path",
                  "_spacing": "          ",
                  "_key": "path",
                  "_value": "'+ dict['LINUX_LOG_DIRECTORY'] +'contentmanagement-.json",
                  "_ending": ","
               }
            },
            "_name": "logging.json",
            "_path": "contentmanagement/Configs/logging.json"
         },
         "hosting": {
            "keys": {
               "update_contentmanagement_port": {
                  "_pattern": "urls",
                  "_spacing": "  ",
                  "_key": "urls",
                  "_value": "http://localhost:'+ dict['UEC_CONTENTMANAGEMENT_PORT'] +';",
                  "_ending": ""
               }
            },
            "_name": "hosting.json",
            "_path": "contentmanagement/Configs/hosting.json"
         }
      }
   },
   "cdcprocessor": {
      "template": "cdcprocessor.template",
      "directory": "Package/cdcprocessor",
      "servicefile": "/lib/systemd/system/cdcprocessor.service",
      "destination": "/opt/suite/cdcprocessor",
      "configs": {
         "appsettings": {
            "keys": {
               "Update_UDAC_port": {
                  "_pattern": "UDACAgentEndpoint",
                  "_spacing": "      ",
                  "_key": "UDACAgentEndpoint",
                  "_value": "http://localhost:'+ dict['UDAC_API_PORT'] +'",
                  "_ending": ""
               }
            },
            "_name": "appsettings.json",
            "_path": "cdcprocessor/appsettings.json"
         },
         "logging": {
            "keys": {
               "UpdateLogPath": {
                  "_pattern": "path",
                  "_spacing": "          ",
                  "_key": "path",
                  "_value": "'+ dict['LINUX_LOG_DIRECTORY'] +'cdcprocessor-.json",
                  "_ending": ","
               }
            },
            "_name": "logging.json",
            "_path": "cdcprocessor/logging.json"
         },
         "hosting": {
            "keys": {
               "update_cdcprocessor_port": {
                  "_pattern": "urls",
                  "_spacing": "  ",
                  "_key": "urls",
                  "_value": "http://localhost:'+ dict['UEC_CDCPROCESSOR_PORT'] +';",
                  "_ending": ""
               }
            },
            "_name": "hosting.json",
            "_path": "cdcprocessor/hosting.json"
         }
      }
   },
   "assignments": {
      "template": "assignments.template",
      "directory": "Package/assignments-ms",
      "servicefile": "/lib/systemd/system/assignments.service",
      "destination": "/opt/suite/assignments-ms",
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
                  "_value": "'+ dict['LINUX_LOG_DIRECTORY'] +'assignments-.json",
                  "_ending": ","
               },
               "Update_assignments_port": {
                  "_pattern": "Url",
                  "_spacing": "        ",
                  "_key": "Url",
                  "_value": "http://localhost:'+ dict['UEC_ASSIGNMENTS_PORT'] +'",
                  "_ending": ""
               }
            },
            "_name": "appsettings.json",
            "_path": "assignments-ms/appsettings.json"
         }
      }
   },
   "apiservice": {
      "template": "udac.template",
      "directory": "Package/apiservice",
      "servicefile": "/lib/systemd/system/apiservice.service",
      "destination": "/opt/suite/apiservice",
      "configs": {
         "appsettings": {
            "keys": {
               "Is_ConnectionString_Encrypted": {
                  "_pattern": "UseEncryptedConnectionString",
                  "_spacing": "        ",
                  "_key": "UseEncryptedConnectionString",
                  "_value": "no",
                  "_ending": ","
               },
               "UpdateConnectionString": {
                  "_pattern": "DefaultConnection",
                  "_spacing": "        ",
                  "_key": "DefaultConnection",
                  "_value": "Data Source='+ dict['UDAC_DB_SERVER'] +';Initial Catalog='+ dict['UDAC_DB_NAME'] +';User ID='+ dict['UDAC_DB_USER'] +';Password='+ dict['UDAC_DB_PASSWORD'] +'",
                  "_ending": ""
               }
            },
            "_name": "appsettings.json",
            "_path": "apiservice/appsettings.json"
         },
         "hosting": {
            "keys": {
               "update_apiservice_port": {
                  "_pattern": "server.urls",
                  "_spacing": "  ",
                  "_key": "server.urls",
                  "_value": "http://localhost:'+ dict['UDAC_API_PORT'] +';;",
                  "_ending": ""
               }
            },
            "_name": "hosting.json",
            "_path": "apiservice/hosting.json"
         }
      }
   }
}'
%}
{% set applications = applications | load_json %}