
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-mr-211008044657807170"
  location = "West Europe"
}

resource "azurerm_spatial_anchors_account" "test" {
  name                = "acCTestdf211008044657807170"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  tags = {
    Environment = "Production"
  }
}
