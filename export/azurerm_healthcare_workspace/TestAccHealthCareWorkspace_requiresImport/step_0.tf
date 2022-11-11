
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-health-221111020545369170"
  location = "West Europe"
}

resource "azurerm_healthcare_workspace" "test" {
  name                = "acctestwk22111170"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
