
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-mr-220811053553922090"
  location = "West Europe"
}

resource "azurerm_spatial_anchors_account" "test" {
  name                = "accTEst_saa220811053553922090"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
