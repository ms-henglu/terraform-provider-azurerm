

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210924004925771952"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestacc4bv1z"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "staging"
  }
}


resource "azurerm_storage_queue" "test" {
  name                 = "mysamplequeue-210924004925771952"
  storage_account_name = azurerm_storage_account.test.name
}
