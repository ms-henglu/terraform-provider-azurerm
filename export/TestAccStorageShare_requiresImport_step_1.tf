


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220623224003354326"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestaccdcx0m"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "staging"
  }
}


resource "azurerm_storage_share" "test" {
  name                 = "testsharedcx0m"
  storage_account_name = azurerm_storage_account.test.name
  quota                = 5
}


resource "azurerm_storage_share" "import" {
  name                 = azurerm_storage_share.test.name
  storage_account_name = azurerm_storage_share.test.storage_account_name
  quota                = 5
}
