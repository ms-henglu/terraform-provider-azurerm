
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220415030723259050"
  location = "West Europe"
}

resource "azurerm_logic_app_workflow" "test" {
  name                = "acctestlaw-220415030723259050"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_logic_app_trigger_recurrence" "test" {
  name         = "frequency-trigger"
  logic_app_id = azurerm_logic_app_workflow.test.id
  frequency    = "Month"
  interval     = 1
  start_time   = "2020-01-01T01:02:03Z"
}
