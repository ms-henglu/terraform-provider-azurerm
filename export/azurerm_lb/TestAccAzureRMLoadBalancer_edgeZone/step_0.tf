
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-lb-231020041320209312"
  location = "westus"
}

data "azurerm_extended_locations" "test" {
  location = azurerm_resource_group.test.location
}

resource "azurerm_lb" "test" {
  name                = "acctest-loadbalancer-231020041320209312"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  edge_zone           = data.azurerm_extended_locations.test.extended_locations[0]

  tags = {
    Environment = "production"
    Purpose     = "AcceptanceTests"
  }
}
