
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-health-230721015219632472"
  location = "West Europe"
}

resource "azurerm_healthcare_workspace" "test" {
  name                = "acctestwk23072172"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
