
provider "azurerm" {
  storage_use_azuread = true
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230313022003219438"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestaccy6rx7"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "staging"
  }
}

resource "azurerm_storage_queue" "test" {
  name                 = "mysamplequeue-230313022003219438"
  storage_account_name = azurerm_storage_account.test.name
}
