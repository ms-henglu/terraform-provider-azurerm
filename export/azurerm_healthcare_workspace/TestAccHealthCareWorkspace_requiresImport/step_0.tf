
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-health-230922061224916784"
  location = "West Europe"
}

resource "azurerm_healthcare_workspace" "test" {
  name                = "acctestwk23092284"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
