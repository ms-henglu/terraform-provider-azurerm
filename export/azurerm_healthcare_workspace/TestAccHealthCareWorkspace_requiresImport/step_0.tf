
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-health-230120054653680213"
  location = "West Europe"
}

resource "azurerm_healthcare_workspace" "test" {
  name                = "acctestwk23012013"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
