
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  display_name = "acctestmg-230519075402514958"
}

resource "azurerm_policy_definition" "test" {
  name                = "acctestpol-230519075402514958"
  policy_type         = "Custom"
  mode                = "All"
  display_name        = "acctestpol-230519075402514958"
  management_group_id = azurerm_management_group.test.id

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
