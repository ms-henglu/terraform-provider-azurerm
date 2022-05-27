

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220527024834344839"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestaccr460w"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "staging"
  }
}


resource "azurerm_storage_queue" "test" {
  name                 = "mysamplequeue-220527024834344839"
  storage_account_name = azurerm_storage_account.test.name

  metadata = {
    hello = "world"
    rick  = "M0rty"
  }
}
