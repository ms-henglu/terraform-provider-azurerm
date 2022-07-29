
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-health-220729032808258374"
  location = "West Europe"
}

resource "azurerm_healthcare_workspace" "test" {
  name                = "acctestwk22072974"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
