
provider "azurerm" {
  storage_use_azuread = true
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211015014901346201"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestaccrbo7w"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "staging"
  }
}

resource "azurerm_storage_queue" "test" {
  name                 = "mysamplequeue-211015014901346201"
  storage_account_name = azurerm_storage_account.test.name
}
