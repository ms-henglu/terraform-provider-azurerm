

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-sentinel-231013044214587557"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctest-workspace-231013044214587557"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
}

resource "azurerm_sentinel_log_analytics_workspace_onboarding" "test" {
  workspace_id = azurerm_log_analytics_workspace.test.id
}




data "azurerm_client_config" "current" {}

data "azurerm_managed_api" "test" {
  name     = "azuresentinel"
  location = azurerm_resource_group.test.location
}

resource "azurerm_api_connection" "test" {
  managed_api_id      = data.azurerm_managed_api.test.id
  name                = "azuresentinel-231013044214587557"
  resource_group_name = azurerm_resource_group.test.name
  parameter_values = {
    "token:TenantId"     = data.azurerm_client_config.current.tenant_id
    "token:clientId"     = data.azurerm_client_config.current.client_id
    "token:clientSecret" = "ARM_CLIENT_SECRET"
    "token:grantType"    = "client_credentials"
  }
  lifecycle {
    ignore_changes = [parameter_values]
  }
}

resource "azurerm_logic_app_workflow" "test" {
  name                = "acctestLogicApp-231013044214587557"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  parameters = {
    "$connections" = jsonencode({
      azuresentinel = {
        connectionId         = azurerm_api_connection.test.id
        connectionName       = azurerm_api_connection.test.name
        connectionProperties = {}
        id                   = data.azurerm_managed_api.test.id
      }
    })
  }

  workflow_parameters = {
    "$connections" = jsonencode({
      defaultValue = {}
      type         = "Object"
    })
  }
}

resource "azurerm_logic_app_trigger_custom" "test" {
  name         = "Microsoft_Sentinel_alert"
  logic_app_id = azurerm_logic_app_workflow.test.id
  body         = <<BODY
{
    "type": "ApiConnectionWebhook",
    "inputs": {
        "body": {
            "callback_url": "@{listCallbackUrl()}"
        },
        "host": {
            "connection": {
                "name": "@parameters('$connections')['azuresentinel']['connectionId']"
            }
        },
        "path": "/subscribe"
    }
}
BODY
}


data "azurerm_role_definition" "sentinel" {
  name  = "Microsoft Sentinel Automation Contributor"
  scope = azurerm_resource_group.test.id
}

data "azuread_service_principal" "sentinel" {
  application_id = "98785600-1bb7-4fb9-b9fa-19afe2c8a360"
}

resource "azurerm_role_assignment" "test" {
  scope              = azurerm_resource_group.test.id
  role_definition_id = data.azurerm_role_definition.sentinel.id
  principal_id       = data.azuread_service_principal.sentinel.object_id
}

resource "azurerm_sentinel_automation_rule" "test" {
  name                       = "f6693d9b-80dc-4602-8764-534659f4f63c"
  log_analytics_workspace_id = azurerm_sentinel_log_analytics_workspace_onboarding.test.workspace_id
  display_name               = "acctest-SentinelAutoRule-231013044214587557-update"
  order                      = 1
  triggers_on                = "Alerts"
  action_playbook {
    logic_app_id = azurerm_logic_app_workflow.test.id
    order        = 1
  }
  condition_json = "[]"

  depends_on = [azurerm_logic_app_trigger_custom.test, azurerm_role_assignment.test]
}




