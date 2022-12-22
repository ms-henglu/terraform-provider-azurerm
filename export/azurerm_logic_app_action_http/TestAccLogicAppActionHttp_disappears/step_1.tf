
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221222034908759746"
  location = "West Europe"
}

resource "azurerm_logic_app_workflow" "test" {
  name                = "acctestlaw-221222034908759746"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
