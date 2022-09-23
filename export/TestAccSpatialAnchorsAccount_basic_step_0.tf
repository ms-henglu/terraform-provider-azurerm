
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-mr-220923012107543427"
  location = "West Europe"
}

resource "azurerm_spatial_anchors_account" "test" {
  name                = "accTEst_saa220923012107543427"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
