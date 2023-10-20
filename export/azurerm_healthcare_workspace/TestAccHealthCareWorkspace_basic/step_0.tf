
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-health-231020041157162096"
  location = "West Europe"
}

resource "azurerm_healthcare_workspace" "test" {
  name                = "acctestwk23102096"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
