

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220204060728572675"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestacchrduv"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "staging"
  }
}


resource "azurerm_storage_queue" "test" {
  name                 = "mysamplequeue-220204060728572675"
  storage_account_name = azurerm_storage_account.test.name
}
