
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-mr-211029015854013142"
  location = "West Europe"
}

resource "azurerm_spatial_anchors_account" "test" {
  name                = "accTEst_saa211029015854013142"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
