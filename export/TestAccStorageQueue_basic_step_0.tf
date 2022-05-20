

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220520041239590338"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestacctwa2n"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "staging"
  }
}


resource "azurerm_storage_queue" "test" {
  name                 = "mysamplequeue-220520041239590338"
  storage_account_name = azurerm_storage_account.test.name
}
