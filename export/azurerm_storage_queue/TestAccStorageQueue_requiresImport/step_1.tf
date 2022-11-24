


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221124182408799066"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestaccpj0i7"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "staging"
  }
}


resource "azurerm_storage_queue" "test" {
  name                 = "mysamplequeue-221124182408799066"
  storage_account_name = azurerm_storage_account.test.name
}


resource "azurerm_storage_queue" "import" {
  name                 = azurerm_storage_queue.test.name
  storage_account_name = azurerm_storage_queue.test.storage_account_name
}
