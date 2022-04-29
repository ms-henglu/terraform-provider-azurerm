
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-health-220429075457628826"
  location = "West Europe"
}

resource "azurerm_healthcare_workspace" "test" {
  name                = "acctestwk22042926"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
