

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220114014844226052"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestaccf1rie"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "staging"
  }
}


resource "azurerm_storage_queue" "test" {
  name                 = "mysamplequeue-220114014844226052"
  storage_account_name = azurerm_storage_account.test.name

  metadata = {
    hello = "world"
    rick  = "M0rty"
  }
}
