
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220811053502890797"
  location = "West Europe"
}

resource "azurerm_logic_app_workflow" "test" {
  name                = "acctestlaw-220811053502890797"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
