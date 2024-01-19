
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119025300928413"
  location = "West Europe"
}

resource "azurerm_logic_app_workflow" "test" {
  name                = "acctestlaw-240119025300928413"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_logic_app_trigger_recurrence" "test" {
  name         = "frequency-trigger"
  logic_app_id = azurerm_logic_app_workflow.test.id
  frequency    = "Week"
  interval     = 1
}
