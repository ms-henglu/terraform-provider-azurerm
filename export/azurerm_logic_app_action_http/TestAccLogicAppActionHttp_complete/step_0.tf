

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230106031625443601"
  location = "West Europe"
}

resource "azurerm_logic_app_workflow" "test" {
  name                = "acctestlaw-230106031625443601"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}


resource "azurerm_logic_app_action_http" "test" {
  name         = "action230106031625443601"
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
