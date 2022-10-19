
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-health-221019060648545339"
  location = "West Europe"
}

resource "azurerm_healthcare_workspace" "test" {
  name                = "acctestwk22101939"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
