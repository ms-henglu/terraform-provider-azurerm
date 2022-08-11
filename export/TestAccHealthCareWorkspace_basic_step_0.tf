
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-health-220811053338210686"
  location = "West Europe"
}

resource "azurerm_healthcare_workspace" "test" {
  name                = "acctestwk22081186"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
