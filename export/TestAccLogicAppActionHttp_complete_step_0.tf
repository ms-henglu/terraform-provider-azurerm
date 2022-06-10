

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220610022750935568"
  location = "West Europe"
}

resource "azurerm_logic_app_workflow" "test" {
  name                = "acctestlaw-220610022750935568"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}


resource "azurerm_logic_app_action_http" "test" {
  name         = "action220610022750935568"
  logic_app_id = azurerm_logic_app_workflow.test.id
  method       = "GET"
  uri          = "http://example.com/hello"
  body         = <<BODY
{
    "description": "test description",
    "inputs": {
        "variables": [
            {
                "name": "test name",
                "type": "Integer",
                "value": 1
            }
        ]
    }
}
BODY
}
