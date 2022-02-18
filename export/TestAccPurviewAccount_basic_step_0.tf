
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-purview-220218071142727347"
  location = "West Europe"
}


resource "azurerm_purview_account" "test" {
  name                = "acctestsw220218071142727347"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
