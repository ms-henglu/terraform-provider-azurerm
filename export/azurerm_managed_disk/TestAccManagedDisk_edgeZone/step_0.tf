
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240105063504043367"
  location = "westus"
}

data "azurerm_extended_locations" "test" {
  location = azurerm_resource_group.test.location
}

resource "azurerm_managed_disk" "test" {
  name                 = "acctestd-240105063504043367"
  location             = azurerm_resource_group.test.location
  resource_group_name  = azurerm_resource_group.test.name
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = "1"
  edge_zone            = data.azurerm_extended_locations.test.extended_locations[0]

  tags = {
    environment = "acctest"
    cost-center = "ops"
  }
}
