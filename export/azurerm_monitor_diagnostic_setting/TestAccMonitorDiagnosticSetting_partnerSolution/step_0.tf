
provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221111020844399030"
  location = "West Europe"
}

resource "azurerm_key_vault" "test" {
  name                = "acctest22111102084439903"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"
}

resource "azurerm_elastic_cloud_elasticsearch" "test" {
  name                        = "acctest-elastic22111102084439903"
  resource_group_name         = azurerm_resource_group.test.name
  location                    = azurerm_resource_group.test.location
  sku_name                    = "ess-monthly-consumption_Monthly"
  elastic_cloud_email_address = "user@example.com"
}

resource "azurerm_monitor_diagnostic_setting" "test" {
  name                = "acctest-DS-221111020844399030"
  target_resource_id  = azurerm_key_vault.test.id
  partner_solution_id = azurerm_elastic_cloud_elasticsearch.test.id

  log {
    category = "AuditEvent"
    enabled  = false

    retention_policy {
      enabled = false
    }
  }

  log {
    category = "AzurePolicyEvaluationDetails"
    enabled  = false

    retention_policy {
      days    = 0
      enabled = false
    }
  }

  metric {
    category = "AllMetrics"

    retention_policy {
      enabled = false
    }
  }
}
