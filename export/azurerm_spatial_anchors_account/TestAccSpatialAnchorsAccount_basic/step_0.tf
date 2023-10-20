
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-mr-231020041447517459"
  location = "West Europe"
}

resource "azurerm_spatial_anchors_account" "test" {
  name                = "accTEst_saa231020041447517459"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
