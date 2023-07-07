
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-health-230707010434147374"
  location = "West Europe"
}

resource "azurerm_healthcare_workspace" "test" {
  name                = "acctestwk23070774"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
