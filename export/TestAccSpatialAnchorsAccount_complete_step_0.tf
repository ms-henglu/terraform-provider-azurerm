
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-mr-211001021017078222"
  location = "West Europe"
}

resource "azurerm_spatial_anchors_account" "test" {
  name                = "acCTestdf211001021017078222"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  tags = {
    Environment = "Production"
  }
}
