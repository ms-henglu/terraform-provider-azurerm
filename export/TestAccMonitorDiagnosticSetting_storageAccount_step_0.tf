
provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211015014525562340"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctest21101501452556234"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_replication_type = "LRS"
  account_tier             = "Standard"
}

resource "azurerm_key_vault" "test" {
  name                = "acctest21101501452556234"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"
}

resource "azurerm_monitor_diagnostic_setting" "test" {
  name               = "acctest-DS-211015014525562340"
  target_resource_id = azurerm_key_vault.test.id
  storage_account_id = azurerm_storage_account.test.id

  log {
    category = "AuditEvent"
    enabled  = false

    retention_policy {
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
