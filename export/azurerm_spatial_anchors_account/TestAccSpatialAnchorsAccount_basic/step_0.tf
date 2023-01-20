
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-mr-230120054855390163"
  location = "West Europe"
}

resource "azurerm_spatial_anchors_account" "test" {
  name                = "accTEst_saa230120054855390163"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
