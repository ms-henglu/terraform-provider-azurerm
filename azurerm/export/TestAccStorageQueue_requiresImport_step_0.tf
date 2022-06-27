

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220627132417135940"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestacctea4i"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "staging"
  }
}


resource "azurerm_storage_queue" "test" {
  name                 = "mysamplequeue-220627132417135940"
  storage_account_name = azurerm_storage_account.test.name
}
