
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-health-240105063922893912"
  location = "West Europe"
}

resource "azurerm_healthcare_workspace" "test" {
  name                = "acctestwk24010512"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
