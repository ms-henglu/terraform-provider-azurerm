
provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {
}


data "azurerm_subscription" "current" {
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240311032620075709"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctest24031103262007570"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_replication_type = "LRS"
  account_tier             = "Standard"
}


resource "azurerm_monitor_diagnostic_setting" "test" {
  name               = "acctest-DS-240311032620075709"
  target_resource_id = data.azurerm_subscription.current.id
  storage_account_id = azurerm_storage_account.test.id

  enabled_log {
    category = "Administrative"
  }

  enabled_log {
    category = "Alert"
  }

  enabled_log {
    category = "Autoscale"
  }

  enabled_log {
    category = "Policy"
  }

  enabled_log {
    category = "Recommendation"
  }

  enabled_log {
    category = "ResourceHealth"
  }

  enabled_log {
    category = "Security"
  }

  enabled_log {
    category = "ServiceHealth"
  }
}
