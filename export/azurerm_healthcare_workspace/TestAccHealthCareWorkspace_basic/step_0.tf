
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-health-230526085203558398"
  location = "West Europe"
}

resource "azurerm_healthcare_workspace" "test" {
  name                = "acctestwk23052698"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
