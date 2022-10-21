
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-health-221021034150407628"
  location = "West Europe"
}

resource "azurerm_healthcare_workspace" "test" {
  name                = "acctestwk22102128"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
