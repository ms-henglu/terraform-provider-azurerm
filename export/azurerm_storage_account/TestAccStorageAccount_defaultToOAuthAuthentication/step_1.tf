
provider "azurerm" {
  features {}
  storage_use_azuread = true
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-storage-240119025908681441"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                = "unlikely23exst2acctq74p3"
  resource_group_name = azurerm_resource_group.test.name

  location                        = azurerm_resource_group.test.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  default_to_oauth_authentication = false

  tags = {
    environment = "production"
  }
}
