
provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {
}


data "azurerm_subscription" "current" {
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220812015446185910"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctest22081201544618591"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_replication_type = "LRS"
  account_tier             = "Standard"
}


resource "azurerm_monitor_diagnostic_setting" "test" {
  name               = "acctest-DS-220812015446185910"
  target_resource_id = data.azurerm_subscription.current.id
  storage_account_id = azurerm_storage_account.test.id

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
