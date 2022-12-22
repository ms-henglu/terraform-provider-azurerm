
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-health-221222034735369930"
  location = "West Europe"
}

resource "azurerm_healthcare_workspace" "test" {
  name                = "acctestwk22122230"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
