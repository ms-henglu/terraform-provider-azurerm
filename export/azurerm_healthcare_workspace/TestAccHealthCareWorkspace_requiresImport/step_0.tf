
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-health-221104005459731053"
  location = "West Europe"
}

resource "azurerm_healthcare_workspace" "test" {
  name                = "acctestwk22110453"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
