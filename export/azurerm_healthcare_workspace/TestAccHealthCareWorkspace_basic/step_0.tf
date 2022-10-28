
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-health-221028165028486844"
  location = "West Europe"
}

resource "azurerm_healthcare_workspace" "test" {
  name                = "acctestwk22102844"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
