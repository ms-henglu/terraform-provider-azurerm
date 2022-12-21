
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-health-221221204347967785"
  location = "West Europe"
}

resource "azurerm_healthcare_workspace" "test" {
  name                = "acctestwk22122185"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
