

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220211131315348034"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestaccerq98"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "staging"
  }
}


resource "azurerm_storage_share" "test" {
  name                 = "testshareerq98"
  storage_account_name = azurerm_storage_account.test.name
}
