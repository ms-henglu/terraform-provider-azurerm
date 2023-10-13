
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-health-231013043546656642"
  location = "West Europe"
}

resource "azurerm_healthcare_workspace" "test" {
  name                = "acctestwk23101342"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
