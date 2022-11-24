
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221124181904715546"
  location = "West Europe"
}

resource "azurerm_logic_app_workflow" "test" {
  name                = "acctestlaw-221124181904715546"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
