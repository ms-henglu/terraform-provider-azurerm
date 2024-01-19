


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119025909451482"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsaavuje"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_share" "test" {
  name                 = "fileshare"
  storage_account_name = azurerm_storage_account.test.name
  quota                = 50
}


resource "azurerm_storage_share_directory" "test" {
  name                 = "dir"
  share_name           = azurerm_storage_share.test.name
  storage_account_name = azurerm_storage_account.test.name
}


resource "azurerm_storage_share_directory" "import" {
  name                 = azurerm_storage_share_directory.test.name
  share_name           = azurerm_storage_share_directory.test.share_name
  storage_account_name = azurerm_storage_share_directory.test.storage_account_name
}
