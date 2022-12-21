

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221221204913466517"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestacc1w0fx"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "staging"
  }
}


resource "azurerm_storage_share" "test" {
  name                 = "testshare1w0fx"
  storage_account_name = azurerm_storage_account.test.name
  quota                = 5

  metadata = {
    hello = "world"
    happy = "birthday"
  }
}
