
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240311032620058300"
  location = "West Europe"
}

data "azurerm_client_config" "current" {}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctestLAW-240311032620058300"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_monitor_action_group" "test" {
  name                = "acctestActionGroup-240311032620058300"
  resource_group_name = "${azurerm_resource_group.test.name}"
  short_name          = "acctestag"

  email_receiver {
    name          = "sendtoadmin"
    email_address = "admin@contoso.com"
  }

  email_receiver {
    name                    = "sendtodevops"
    email_address           = "devops@contoso.com"
    use_common_alert_schema = true
  }

  itsm_receiver {
    name                 = "createorupdateticket"
    workspace_id         = "${data.azurerm_client_config.current.subscription_id}|${azurerm_log_analytics_workspace.test.workspace_id}"
    connection_id        = "53de6956-42b4-41ba-be3c-b154cdf17b13"
    ticket_configuration = "{\"PayloadRevision\":0,\"WorkItemType\":\"Incident\",\"UseTemplate\":false,\"WorkItemData\":\"{}\",\"CreateOneWIPerCI\":false}"
    region               = "eastus"
  }

  azure_app_push_receiver {
    name          = "pushtoadmin"
    email_address = "admin@contoso.com"
  }

  sms_receiver {
    name         = "oncallmsg"
    country_code = "1"
    phone_number = "2123456789"
  }

  sms_receiver {
    name         = "remotesupport"
    country_code = "1"
    phone_number = "3123456789"
  }

  webhook_receiver {
    name        = "callmyapiaswell"
    service_uri = "http://example.com/alert"
  }

  webhook_receiver {
    name                    = "callmybackupapi"
    service_uri             = "https://example.com/warning/backup"
    use_common_alert_schema = true
  }

  automation_runbook_receiver {
    name                    = "action_name_1"
    automation_account_id   = "${azurerm_automation_account.test.id}"
    runbook_name            = "${azurerm_automation_runbook.test.name}"
    webhook_resource_id     = "/subscriptions/00000000-0000-0000-0000-000000000000/resourcegroups/rg-runbooks/providers/microsoft.automation/automationaccounts/aaa001/webhooks/webhook_alert"
    is_global_runbook       = true
    service_uri             = "https://s13events.azure-automation.net/webhooks?token=randomtoken"
    use_common_alert_schema = false
  }

  voice_receiver {
    name         = "oncallvoice"
    country_code = "1"
    phone_number = "2123456789"
  }

  logic_app_receiver {
    name                    = "logicappaction"
    resource_id             = "${azurerm_logic_app_workflow.test.id}"
    callback_url            = "http://test-host:100/workflows/fb9c8d79b15f41ce9b12861862f43546/versions/08587100027316071865/triggers/manualTrigger/paths/invoke?api-version=2015-08-01-preview&sp=%2Fversions%2F08587100027316071865%2Ftriggers%2FmanualTrigger%2Frun&sv=1.0&sig=IxEQ_ygZf6WNEQCbjV0Vs6p6Y4DyNEJVAa86U5B4xhk"
    use_common_alert_schema = false
  }

  azure_function_receiver {
    name                     = "funcaction"
    function_app_resource_id = "${azurerm_function_app.test.id}"
    function_name            = "myfunc"
    http_trigger_url         = "https://example.com/trigger"
    use_common_alert_schema  = false
  }

  arm_role_receiver {
    name                    = "Monitoring Reader"
    role_id                 = "43d0d8ad-25c7-4714-9337-8ba259a9fe05"
    use_common_alert_schema = false
  }

  event_hub_receiver {
    name                    = "eventhub-test-action"
    event_hub_name          = azurerm_eventhub.test.name
    event_hub_namespace     = azurerm_eventhub.test.namespace_name
    use_common_alert_schema = false
  }
}

resource "azurerm_automation_account" "test" {
  name                = "acctestAA-240311032620058300"
  location            = "${azurerm_resource_group.test.location}"
  resource_group_name = "${azurerm_resource_group.test.name}"

  sku_name = "Basic"
}

resource "azurerm_automation_runbook" "test" {
  name                    = "Get-AzureVMTutorial"
  location                = "${azurerm_resource_group.test.location}"
  resource_group_name     = "${azurerm_resource_group.test.name}"
  automation_account_name = "${azurerm_automation_account.test.name}"
  log_verbose             = "true"
  log_progress            = "true"
  description             = "This is an test runbook"
  runbook_type            = "PowerShellWorkflow"

  publish_content_link {
    uri = "https://raw.githubusercontent.com/Azure/azure-quickstart-templates/c4935ffb69246a6058eb24f54640f53f69d3ac9f/101-automation-runbook-getvms/Runbooks/Get-AzureVMTutorial.ps1"
  }
}

resource "azurerm_logic_app_workflow" "test" {
  name                = "acctestLA-240311032620058300"
  location            = "${azurerm_resource_group.test.location}"
  resource_group_name = "${azurerm_resource_group.test.name}"
}

resource "azurerm_logic_app_trigger_http_request" "test" {
  name         = "some-http-trigger"
  logic_app_id = "${azurerm_logic_app_workflow.test.id}"

  schema = <<SCHEMA
	{
		"type": "object",
		"properties": {
			"hello": {
				"type": "string"
			}
		}
	}
	SCHEMA
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsauadmu"
  resource_group_name      = "${azurerm_resource_group.test.name}"
  location                 = "${azurerm_resource_group.test.location}"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_app_service_plan" "test" {
  name                = "acctestSP-240311032620058300"
  location            = "${azurerm_resource_group.test.location}"
  resource_group_name = "${azurerm_resource_group.test.name}"

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_function_app" "test" {
  name                       = "acctestFA-240311032620058300"
  location                   = "${azurerm_resource_group.test.location}"
  resource_group_name        = "${azurerm_resource_group.test.name}"
  app_service_plan_id        = "${azurerm_app_service_plan.test.id}"
  storage_account_name       = azurerm_storage_account.test.name
  storage_account_access_key = azurerm_storage_account.test.primary_access_key
}

resource "azurerm_eventhub_namespace" "test" {
  name                = "acceptanceTestEventHubNamespace-240311032620058300"
  location            = "West Europe"
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"
  capacity            = 1
}

resource "azurerm_eventhub" "test" {
  name                = "acceptanceTestEventHub"
  namespace_name      = azurerm_eventhub_namespace.test.name
  resource_group_name = azurerm_resource_group.test.name
  partition_count     = 1
  message_retention   = 1
}


