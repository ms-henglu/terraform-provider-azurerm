
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-health-220623223444766946"
  location = "West Europe"
}

resource "azurerm_healthcare_workspace" "test" {
  name                = "acctestwk22062346"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
