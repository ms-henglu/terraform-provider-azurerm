
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-purview-220311042900074731"
  location = "West Europe"
}


resource "azurerm_purview_account" "test" {
  name                = "acctestsw220311042900074731"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
