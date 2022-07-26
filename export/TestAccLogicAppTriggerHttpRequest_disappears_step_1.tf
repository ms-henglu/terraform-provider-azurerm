
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220726002122104631"
  location = "West Europe"
}

resource "azurerm_logic_app_workflow" "test" {
  name                = "acctestlaw-220726002122104631"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
