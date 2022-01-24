

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220124125733356939"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestacchgww1"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "staging"
  }
}


resource "azurerm_storage_share" "test" {
  name                 = "testsharehgww1"
  storage_account_name = azurerm_storage_account.test.name
}
