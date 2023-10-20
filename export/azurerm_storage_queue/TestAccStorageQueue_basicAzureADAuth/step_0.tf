
provider "azurerm" {
  storage_use_azuread = true
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231020041948505791"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestaccwjpr6"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "staging"
  }
}

resource "azurerm_storage_queue" "test" {
  name                 = "mysamplequeue-231020041948505791"
  storage_account_name = azurerm_storage_account.test.name
}
