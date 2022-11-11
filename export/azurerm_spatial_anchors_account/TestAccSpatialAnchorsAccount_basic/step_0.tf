
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-mr-221111020835169849"
  location = "West Europe"
}

resource "azurerm_spatial_anchors_account" "test" {
  name                = "accTEst_saa221111020835169849"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
