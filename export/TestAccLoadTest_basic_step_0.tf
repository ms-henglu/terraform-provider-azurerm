
provider "azurerm" {
  features {}
}



resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220429065657337726"
  location = "West Europe"
}



resource "azurerm_load_test" "test" {
  name                = "acctestALT-220429065657337726"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
