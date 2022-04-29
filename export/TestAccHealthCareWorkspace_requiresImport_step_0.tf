
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-health-220429075457627241"
  location = "West Europe"
}

resource "azurerm_healthcare_workspace" "test" {
  name                = "acctestwk22042941"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
