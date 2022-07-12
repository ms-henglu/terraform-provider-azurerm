
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-mr-220712042534985724"
  location = "West Europe"
}

resource "azurerm_spatial_anchors_account" "test" {
  name                = "acCTestdf220712042534985724"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  tags = {
    Environment = "Production"
  }
}
