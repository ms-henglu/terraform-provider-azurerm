


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230804030801357872"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestacck0u2k"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "staging"
  }
}


resource "azurerm_storage_share" "test" {
  name                 = "testsharek0u2k"
  storage_account_name = azurerm_storage_account.test.name
  quota                = 5
}


resource "azurerm_storage_share" "import" {
  name                 = azurerm_storage_share.test.name
  storage_account_name = azurerm_storage_share.test.storage_account_name
  quota                = 5
}
