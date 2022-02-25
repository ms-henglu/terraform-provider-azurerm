
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-purview-220225034842707703"
  location = "West Europe"
}


resource "azurerm_purview_account" "test" {
  name                = "acctestsw220225034842707703"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
