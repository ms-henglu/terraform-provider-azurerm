

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220114014844326143"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestaccgy01e"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "staging"
  }
}


resource "azurerm_storage_share" "test" {
  name                 = "testsharegy01e"
  storage_account_name = azurerm_storage_account.test.name
}
