

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210928075949389034"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestacckai30"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "staging"
  }
}


resource "azurerm_storage_share" "test" {
  name                 = "testsharekai30"
  storage_account_name = azurerm_storage_account.test.name
}
