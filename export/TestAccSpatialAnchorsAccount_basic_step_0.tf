
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-mr-221019054636840975"
  location = "West Europe"
}

resource "azurerm_spatial_anchors_account" "test" {
  name                = "accTEst_saa221019054636840975"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
