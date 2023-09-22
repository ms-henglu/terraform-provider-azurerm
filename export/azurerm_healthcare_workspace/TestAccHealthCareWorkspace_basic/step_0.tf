
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-health-230922054224190311"
  location = "West Europe"
}

resource "azurerm_healthcare_workspace" "test" {
  name                = "acctestwk23092211"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
