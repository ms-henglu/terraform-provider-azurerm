
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220429065805967709"
  location = "West Europe"
}

resource "azurerm_monitor_action_group" "test" {
  name                = "acctestActionGroup-220429065805967709"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctestag"
}
