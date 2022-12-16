
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-health-221216013612535217"
  location = "West Europe"
}

resource "azurerm_healthcare_workspace" "test" {
  name                = "acctestwk22121617"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
