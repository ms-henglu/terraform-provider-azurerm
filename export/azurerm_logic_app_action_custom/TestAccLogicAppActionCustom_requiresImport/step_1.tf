


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230512010930945744"
  location = "West Europe"
}

resource "azurerm_logic_app_workflow" "test" {
  name                = "acctestlaw-230512010930945744"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}


resource "azurerm_logic_app_action_custom" "test" {
  name         = "action230512010930945744"
  logic_app_id = azurerm_logic_app_workflow.test.id

  body = <<BODY
{
    "description": "A variable to configure the auto expiration age in days. Configured in negative number. Default is -30 (30 days old).",
    "inputs": {
        "variables": [
            {
                "name": "ExpirationAgeInDays",
                "type": "Integer",
                "value": -30
            }
        ]
    },
    "runAfter": {},
    "type": "InitializeVariable"
}
BODY

}


resource "azurerm_logic_app_action_custom" "import" {
  name         = azurerm_logic_app_action_custom.test.name
  logic_app_id = azurerm_logic_app_action_custom.test.logic_app_id
  body         = azurerm_logic_app_action_custom.test.body
}
