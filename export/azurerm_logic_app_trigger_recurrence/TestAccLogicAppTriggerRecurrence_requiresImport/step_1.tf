

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231016034206860040"
  location = "West Europe"
}

resource "azurerm_logic_app_workflow" "test" {
  name                = "acctestlaw-231016034206860040"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_logic_app_trigger_recurrence" "test" {
  name         = "frequency-trigger"
  logic_app_id = azurerm_logic_app_workflow.test.id
  frequency    = "Month"
  interval     = 1
}


resource "azurerm_logic_app_trigger_recurrence" "import" {
  name         = azurerm_logic_app_trigger_recurrence.test.name
  logic_app_id = azurerm_logic_app_trigger_recurrence.test.logic_app_id
  frequency    = azurerm_logic_app_trigger_recurrence.test.frequency
  interval     = azurerm_logic_app_trigger_recurrence.test.interval
}
