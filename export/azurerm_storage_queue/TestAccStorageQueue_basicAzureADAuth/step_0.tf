
provider "azurerm" {
  storage_use_azuread = true
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230915024302450077"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestacca02b1"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "staging"
  }
}

resource "azurerm_storage_queue" "test" {
  name                 = "mysamplequeue-230915024302450077"
  storage_account_name = azurerm_storage_account.test.name
}
