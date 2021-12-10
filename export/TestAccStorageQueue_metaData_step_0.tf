

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211210025124830228"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestacctj2dg"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "staging"
  }
}


resource "azurerm_storage_queue" "test" {
  name                 = "mysamplequeue-211210025124830228"
  storage_account_name = azurerm_storage_account.test.name

  metadata = {
    hello = "world"
  }
}
