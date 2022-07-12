
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220712042000698535"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsae2w8o"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_batch_account" "test" {
  name                 = "acctestbae2w8o"
  resource_group_name  = azurerm_resource_group.test.name
  location             = azurerm_resource_group.test.location
  pool_allocation_mode = "BatchService"
  storage_account_id   = azurerm_storage_account.test.id
}

resource "azurerm_batch_application" "test" {
  name                = "acctestbatchapp-220712042000698535"
  resource_group_name = azurerm_resource_group.test.name
  account_name        = azurerm_batch_account.test.name
  display_name = "TestAccDisplayName-220712042000698535"
}
