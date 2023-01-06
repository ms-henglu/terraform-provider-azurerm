
provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {
}


data "azurerm_subscription" "current" {
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230106034757772018"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctest23010603475777201"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_replication_type = "LRS"
  account_tier             = "Standard"
}


resource "azurerm_monitor_diagnostic_setting" "test" {
  name                           = "acctest-DS-230106034757772018"
  target_resource_id             = data.azurerm_subscription.current.id
  storage_account_id             = azurerm_storage_account.test.id
  log_analytics_destination_type = "AzureDiagnostics"

  log {
    category = "Administrative"
    enabled  = true
  }

  log {
    category = "Alert"
    enabled  = true
  }

  log {
    category = "Autoscale"
    enabled  = true
  }

  log {
    category = "Policy"
    enabled  = true
  }

  log {
    category = "Recommendation"
    enabled  = true
  }

  log {
    category = "ResourceHealth"
    enabled  = true
  }

  log {
    category = "Security"
    enabled  = true
  }

  log {
    category = "ServiceHealth"
    enabled  = true
  }
}
