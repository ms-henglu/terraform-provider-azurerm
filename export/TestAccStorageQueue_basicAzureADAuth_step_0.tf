
provider "azurerm" {
  storage_use_azuread = true
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211001224608978066"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestaccsh61c"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "staging"
  }
}

resource "azurerm_storage_queue" "test" {
  name                 = "mysamplequeue-211001224608978066"
  storage_account_name = azurerm_storage_account.test.name
}
