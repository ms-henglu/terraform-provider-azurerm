
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-health-220429065553302654"
  location = "West Europe"
}

resource "azurerm_healthcare_workspace" "test" {
  name                = "acctestwk22042954"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
