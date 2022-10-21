
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-health-221021031250686179"
  location = "West Europe"
}

resource "azurerm_healthcare_workspace" "test" {
  name                = "acctestwk22102179"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
