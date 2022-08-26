

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220826003348532391"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestaccsfx6v"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "staging"
  }
}


resource "azurerm_storage_queue" "test" {
  name                 = "mysamplequeue-220826003348532391"
  storage_account_name = azurerm_storage_account.test.name
}
