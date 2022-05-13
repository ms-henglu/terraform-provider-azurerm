

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220513023855448140"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestaccz4krk"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "staging"
  }
}


resource "azurerm_storage_share" "test" {
  name                 = "testsharez4krk"
  storage_account_name = azurerm_storage_account.test.name
  quota                = 5
}
