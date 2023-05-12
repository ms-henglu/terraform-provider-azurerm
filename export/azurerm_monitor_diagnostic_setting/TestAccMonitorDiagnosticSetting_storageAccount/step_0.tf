
provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230512011050442598"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctest23051201105044259"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_replication_type = "LRS"
  account_tier             = "Standard"
}

resource "azurerm_key_vault" "test" {
  name                = "acctest23051201105044259"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"
}

resource "azurerm_monitor_diagnostic_setting" "test" {
  name               = "acctest-DS-230512011050442598"
  target_resource_id = azurerm_key_vault.test.id
  storage_account_id = azurerm_storage_account.test.id

  metric {
    category = "AllMetrics"

    retention_policy {
      days    = 0
      enabled = false
    }
  }
}
