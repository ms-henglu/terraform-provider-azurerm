

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230613072729376053"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestaccve1zs"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "staging"
  }
}


resource "azurerm_storage_share" "test" {
  name                 = "testshareve1zs"
  storage_account_name = azurerm_storage_account.test.name
  quota                = 5
}
