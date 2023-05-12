
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-storage-230512011501334365"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "unlikely23exst2acct32b6j"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "production"
  }
}

resource "azurerm_storage_account_network_rules" "test" {
  storage_account_id = azurerm_storage_account.test.id

  default_action             = "Deny"
  bypass                     = ["None"]
  ip_rules                   = []
  virtual_network_subnet_ids = []
}
