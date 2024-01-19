
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119025027132689"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestegst240119025089"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_eventgrid_system_topic" "test" {
  name                   = "acctesteg-240119025027132689"
  location               = azurerm_resource_group.test.location
  resource_group_name    = azurerm_resource_group.test.name
  source_arm_resource_id = azurerm_storage_account.test.id
  topic_type             = "Microsoft.Storage.StorageAccounts"

  identity {
    type = "SystemAssigned"
  }
}
