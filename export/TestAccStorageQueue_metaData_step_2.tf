

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211217075936154421"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestacczj82n"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "staging"
  }
}


resource "azurerm_storage_queue" "test" {
  name                 = "mysamplequeue-211217075936154421"
  storage_account_name = azurerm_storage_account.test.name

  metadata = {
    hello = "world"
    rick  = "M0rty"
  }
}
