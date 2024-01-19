

provider "azurerm" {
  features {}
}

resource "azurerm_policy_definition" "test" {
  name         = "acctestpol-240119025606768800"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "acctestpol-240119025606768800"

  policy_rule = <<POLICY_RULE
	{
    "if": {
      "not": {
        "field": "location",
        "in": "[parameters('allowedLocations')]"
      }
    },
    "then": {
      "effect": "audit"
    }
  }
POLICY_RULE

  parameters = <<PARAMETERS
	{
    "allowedLocations": {
      "type": "Array",
      "metadata": {
        "description": "The list of allowed locations for resources.",
        "displayName": "Allowed locations",
        "strongType": "location"
      }
    }
  }
PARAMETERS
}


resource "azurerm_policy_definition" "import" {
  name         = azurerm_policy_definition.test.name
  policy_type  = azurerm_policy_definition.test.policy_type
  mode         = azurerm_policy_definition.test.mode
  display_name = azurerm_policy_definition.test.display_name
  policy_rule  = azurerm_policy_definition.test.policy_rule
  parameters   = azurerm_policy_definition.test.parameters
}
