

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220124122740882401"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestaccoqh6n"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "staging"
  }
}


resource "azurerm_storage_queue" "test" {
  name                 = "mysamplequeue-220124122740882401"
  storage_account_name = azurerm_storage_account.test.name
}
