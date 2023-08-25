


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230825024815961843"
  location = "West Europe"
}

resource "azurerm_logic_app_workflow" "test" {
  name                = "acctestlaw-230825024815961843"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}


resource "azurerm_logic_app_trigger_custom" "test" {
  name         = "recurrence-230825024815961843"
  logic_app_id = azurerm_logic_app_workflow.test.id

  body = <<BODY
{
  "recurrence": {
    "frequency": "Day",
    "interval": 1
  },
  "type": "Recurrence"
}
BODY

}


resource "azurerm_logic_app_trigger_custom" "import" {
  name         = azurerm_logic_app_trigger_custom.test.name
  logic_app_id = azurerm_logic_app_trigger_custom.test.logic_app_id
  body         = azurerm_logic_app_trigger_custom.test.body
}
