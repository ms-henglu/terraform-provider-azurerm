

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230421023011135545"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestacc1k0ky"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "staging"
  }
}


resource "azurerm_storage_share" "test" {
  name                 = "testshare1k0ky"
  storage_account_name = azurerm_storage_account.test.name
  quota                = 5
}
