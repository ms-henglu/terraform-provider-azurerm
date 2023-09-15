

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230915024302456671"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsaqt8bh"
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
  name                 = "UpperCaseCharacterS"
  share_name           = azurerm_storage_share.test.name
  storage_account_name = azurerm_storage_account.test.name
}
