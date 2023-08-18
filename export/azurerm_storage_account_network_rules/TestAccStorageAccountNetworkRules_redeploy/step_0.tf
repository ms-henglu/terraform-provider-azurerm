
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-storage-230818024852338464"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsadn304"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_account_network_rules" "test" {
  storage_account_id = azurerm_storage_account.test.id

  default_action = "Deny"
  ip_rules       = ["198.1.1.0"]
  bypass         = ["Metrics"]
}
