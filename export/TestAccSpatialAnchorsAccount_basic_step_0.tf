
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-mr-220610092951657188"
  location = "West Europe"
}

resource "azurerm_spatial_anchors_account" "test" {
  name                = "accTEst_saa220610092951657188"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
