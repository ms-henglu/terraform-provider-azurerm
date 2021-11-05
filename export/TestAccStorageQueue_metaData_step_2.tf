

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211105040547537618"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestaccpt2f1"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "staging"
  }
}


resource "azurerm_storage_queue" "test" {
  name                 = "mysamplequeue-211105040547537618"
  storage_account_name = azurerm_storage_account.test.name

  metadata = {
    hello = "world"
    rick  = "M0rty"
  }
}
