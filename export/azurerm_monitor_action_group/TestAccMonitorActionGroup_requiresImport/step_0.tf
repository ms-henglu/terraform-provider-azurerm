
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221111013922336818"
  location = "West Europe"
}

resource "azurerm_monitor_action_group" "test" {
  name                = "acctestActionGroup-221111013922336818"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctestag"
}
