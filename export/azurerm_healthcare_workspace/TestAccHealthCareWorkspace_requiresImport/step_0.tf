
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-health-221124181732618393"
  location = "West Europe"
}

resource "azurerm_healthcare_workspace" "test" {
  name                = "acctestwk22112493"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
