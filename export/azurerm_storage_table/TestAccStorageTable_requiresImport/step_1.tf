

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230316222409062216"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestacc7f1pl"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "staging"
  }
}

resource "azurerm_storage_table" "test" {
  name                 = "acctestst230316222409062216"
  storage_account_name = azurerm_storage_account.test.name
}


resource "azurerm_storage_table" "import" {
  name                 = azurerm_storage_table.test.name
  storage_account_name = azurerm_storage_table.test.storage_account_name
}
