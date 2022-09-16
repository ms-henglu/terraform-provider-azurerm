
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-health-220916011534186694"
  location = "West Europe"
}

resource "azurerm_healthcare_workspace" "test" {
  name                = "acctestwk22091694"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
