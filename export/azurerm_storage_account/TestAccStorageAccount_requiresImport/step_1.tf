

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-storage-240105061635838652"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                = "unlikely23exst2acct293or"
  resource_group_name = azurerm_resource_group.test.name

  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "production"
  }
}


resource "azurerm_storage_account" "import" {
  name                     = azurerm_storage_account.test.name
  resource_group_name      = azurerm_storage_account.test.resource_group_name
  location                 = azurerm_storage_account.test.location
  account_tier             = azurerm_storage_account.test.account_tier
  account_replication_type = azurerm_storage_account.test.account_replication_type
}
