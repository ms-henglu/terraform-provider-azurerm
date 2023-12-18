
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-logic-231218072032611374"
  location = "West Europe"
}

resource "azurerm_logic_app_workflow" "test" {
  name                = "acctestlaw-231218072032611374"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
