
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-mr-230707010648739062"
  location = "West Europe"
}

resource "azurerm_spatial_anchors_account" "test" {
  name                = "accTEst_saa230707010648739062"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
