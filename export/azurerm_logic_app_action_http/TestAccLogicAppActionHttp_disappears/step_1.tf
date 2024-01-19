
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119022328317599"
  location = "West Europe"
}

resource "azurerm_logic_app_workflow" "test" {
  name                = "acctestlaw-240119022328317599"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
