

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211001224609084758"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestacc2a0rx"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "staging"
  }
}


resource "azurerm_storage_share" "test" {
  name                 = "testshare2a0rx"
  storage_account_name = azurerm_storage_account.test.name

  metadata = {
    hello = "world"
  }
}
