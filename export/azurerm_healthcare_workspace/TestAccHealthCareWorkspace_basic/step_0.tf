
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-health-240311032235813400"
  location = "West Europe"
}

resource "azurerm_healthcare_workspace" "test" {
  name                = "acctestwk24031100"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
