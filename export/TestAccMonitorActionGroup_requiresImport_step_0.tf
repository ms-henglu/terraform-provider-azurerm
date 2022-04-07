
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220407231226626748"
  location = "West Europe"
}

resource "azurerm_monitor_action_group" "test" {
  name                = "acctestActionGroup-220407231226626748"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctestag"
}
