

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240315124154218592"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsaf843w"
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
  name             = "123--parent-dir"
  storage_share_id = azurerm_storage_share.test.id
}

resource "azurerm_storage_share_directory" "child_one" {
  name             = "${azurerm_storage_share_directory.parent.name}/child1"
  storage_share_id = azurerm_storage_share.test.id
}

resource "azurerm_storage_share_directory" "child_two" {
  name             = "${azurerm_storage_share_directory.child_one.name}/childtwo--123"
  storage_share_id = azurerm_storage_share.test.id
}

resource "azurerm_storage_share_directory" "multiple_child_one" {
  name             = "${azurerm_storage_share_directory.parent.name}/c"
  storage_share_id = azurerm_storage_share.test.id
}
