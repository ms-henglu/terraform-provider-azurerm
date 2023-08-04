
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-health-230804030028032842"
  location = "West Europe"
}

resource "azurerm_healthcare_workspace" "test" {
  name                = "acctestwk23080442"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
