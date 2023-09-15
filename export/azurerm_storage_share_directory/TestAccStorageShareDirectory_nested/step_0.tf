

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230915024302450009"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsa0vylf"
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


resource "azurerm_storage_share_directory" "parent" {
  name                 = "123--parent-dir"
  share_name           = azurerm_storage_share.test.name
  storage_account_name = azurerm_storage_account.test.name
}

resource "azurerm_storage_share_directory" "child_one" {
  name                 = "${azurerm_storage_share_directory.parent.name}/child1"
  share_name           = azurerm_storage_share.test.name
  storage_account_name = azurerm_storage_account.test.name
}

resource "azurerm_storage_share_directory" "child_two" {
  name                 = "${azurerm_storage_share_directory.child_one.name}/childtwo--123"
  share_name           = azurerm_storage_share.test.name
  storage_account_name = azurerm_storage_account.test.name
}

resource "azurerm_storage_share_directory" "multiple_child_one" {
  name                 = "${azurerm_storage_share_directory.parent.name}/c"
  share_name           = azurerm_storage_share.test.name
  storage_account_name = azurerm_storage_account.test.name
}
