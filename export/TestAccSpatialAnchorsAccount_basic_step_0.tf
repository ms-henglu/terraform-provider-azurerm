
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-mr-210825045019989930"
  location = "West Europe"
}

resource "azurerm_spatial_anchors_account" "test" {
  name                = "accTEst_saa210825045019989930"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
