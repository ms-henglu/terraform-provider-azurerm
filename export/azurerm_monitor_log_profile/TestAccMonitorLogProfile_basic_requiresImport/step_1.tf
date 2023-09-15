

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230915023817063742"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsaff0zr"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
}

resource "azurerm_monitor_log_profile" "test" {
  name = "acctestlp-230915023817063742"

  categories = [
    "Action",
  ]

  locations = [
    "West Europe",
  ]

  storage_account_id = azurerm_storage_account.test.id

  retention_policy {
    enabled = true
    days    = 7
  }
}


resource "azurerm_monitor_log_profile" "import" {
  name               = azurerm_monitor_log_profile.test.name
  categories         = azurerm_monitor_log_profile.test.categories
  locations          = azurerm_monitor_log_profile.test.locations
  storage_account_id = azurerm_monitor_log_profile.test.storage_account_id

  retention_policy {
    enabled = true
    days    = 7
  }
}
