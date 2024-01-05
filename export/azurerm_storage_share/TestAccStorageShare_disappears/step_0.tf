

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240105061636393292"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestacc8da6j"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "staging"
  }
}


resource "azurerm_storage_share" "test" {
  name                 = "testshare8da6j"
  storage_account_name = azurerm_storage_account.test.name
  quota                = 5
}
