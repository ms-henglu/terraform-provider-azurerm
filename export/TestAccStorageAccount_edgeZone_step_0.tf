
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-storage-220324180850822474"
  location = "westus"
}

resource "azurerm_storage_account" "test" {
  name                     = "unlikely23exst2acctmtbsv"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Premium"
  account_replication_type = "LRS"
  edge_zone                = data.azurerm_extended_locations.test.extended_locations[0]

  tags = {
    environment = "production"
  }
}
