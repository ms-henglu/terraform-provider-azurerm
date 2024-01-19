
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119025027124776"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestegst240119025076"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_eventgrid_system_topic" "test" {
  name                   = "acctestEGST240119025027124776"
  location               = azurerm_resource_group.test.location
  resource_group_name    = azurerm_resource_group.test.name
  source_arm_resource_id = azurerm_storage_account.test.id
  topic_type             = "Microsoft.Storage.StorageAccounts"
}
