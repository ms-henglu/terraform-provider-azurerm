

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210825041339081030"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestaccb014q"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "staging"
  }
}


resource "azurerm_storage_share" "test" {
  name                 = "testshareb014q"
  storage_account_name = azurerm_storage_account.test.name

  metadata = {
    hello = "world"
  }
}
