

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220712042841059490"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestaccz8do1"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "staging"
  }
}


resource "azurerm_storage_share" "test" {
  name                 = "testsharez8do1"
  storage_account_name = azurerm_storage_account.test.name
  quota                = 5
}
