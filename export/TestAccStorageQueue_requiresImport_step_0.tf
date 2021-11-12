

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211112021327087633"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestacceoi2e"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "staging"
  }
}


resource "azurerm_storage_queue" "test" {
  name                 = "mysamplequeue-211112021327087633"
  storage_account_name = azurerm_storage_account.test.name
}
