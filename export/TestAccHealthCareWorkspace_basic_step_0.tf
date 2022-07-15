
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-health-220715004510619395"
  location = "West Europe"
}

resource "azurerm_healthcare_workspace" "test" {
  name                = "acctestwk22071595"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
