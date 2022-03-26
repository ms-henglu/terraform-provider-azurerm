
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-health-220326010617601552"
  location = "West Europe"
}

resource "azurerm_healthcare_workspace" "test" {
  name                = "acctestwk22032652"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
