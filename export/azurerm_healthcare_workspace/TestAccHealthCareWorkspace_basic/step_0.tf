
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-health-230414021416815158"
  location = "West Europe"
}

resource "azurerm_healthcare_workspace" "test" {
  name                = "acctestwk23041458"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
