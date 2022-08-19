
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-mr-220819165453084857"
  location = "West Europe"
}

resource "azurerm_spatial_anchors_account" "test" {
  name                = "accTEst_saa220819165453084857"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
