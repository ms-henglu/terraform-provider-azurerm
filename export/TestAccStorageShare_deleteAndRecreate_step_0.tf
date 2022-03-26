

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220326011300708273"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestacc41p89"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "staging"
  }
}


resource "azurerm_storage_share" "test" {
  name                 = "testshare41p89"
  storage_account_name = azurerm_storage_account.test.name
  quota                = 1
}
