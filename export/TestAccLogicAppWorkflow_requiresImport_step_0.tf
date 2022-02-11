
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-logic-220211130811928006"
  location = "West Europe"
}

resource "azurerm_logic_app_workflow" "test" {
  name                = "acctestlaw-220211130811928006"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
