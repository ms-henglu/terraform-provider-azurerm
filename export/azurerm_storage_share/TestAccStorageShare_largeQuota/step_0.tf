
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-storageshare-221202040543342759"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsharepk9yz"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Premium"
  account_replication_type = "LRS"
  account_kind             = "FileStorage"

  tags = {
    environment = "staging"
  }
}

resource "azurerm_storage_share" "test" {
  name                 = "testsharepk9yz"
  storage_account_name = azurerm_storage_account.test.name
  quota                = 6000
}
