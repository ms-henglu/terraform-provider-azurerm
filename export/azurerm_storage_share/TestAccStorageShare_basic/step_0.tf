

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230203064226933159"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestaccm22ky"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "staging"
  }
}


resource "azurerm_storage_share" "test" {
  name                 = "testsharem22ky"
  storage_account_name = azurerm_storage_account.test.name
  quota                = 5
}
