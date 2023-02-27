
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-health-230227175520547837"
  location = "West Europe"
}

resource "azurerm_healthcare_workspace" "test" {
  name                = "acctestwk23022737"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
