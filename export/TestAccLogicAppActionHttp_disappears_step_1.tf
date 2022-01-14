
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220114014418346905"
  location = "West Europe"
}

resource "azurerm_logic_app_workflow" "test" {
  name                = "acctestlaw-220114014418346905"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
