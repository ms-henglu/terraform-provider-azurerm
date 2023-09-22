


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230922062018265013"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestaccivc4i"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "staging"
  }
}


resource "azurerm_storage_queue" "test" {
  name                 = "mysamplequeue-230922062018265013"
  storage_account_name = azurerm_storage_account.test.name
}


resource "azurerm_storage_queue" "import" {
  name                 = azurerm_storage_queue.test.name
  storage_account_name = azurerm_storage_queue.test.storage_account_name
}
