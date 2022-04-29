
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-mr-220429075654768657"
  location = "West Europe"
}

resource "azurerm_spatial_anchors_account" "test" {
  name                = "accTEst_saa220429075654768657"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
