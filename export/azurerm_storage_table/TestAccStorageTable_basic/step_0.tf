
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230512011501863770"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestacck2qra"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "staging"
  }
}

resource "azurerm_storage_table" "test" {
  name                 = "acctestst230512011501863770"
  storage_account_name = azurerm_storage_account.test.name
}
