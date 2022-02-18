
provider "azurerm" {
  features {}
}

resource "azurerm_policy_definition" "test" {
  name         = "acctestpol-220218071117643184"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "acctestpol-220218071117643184"

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

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220218071117643184"
  location = "West Europe"
}

resource "azurerm_policy_assignment" "test" {
  name                 = "acctestpa-220218071117643184"
  scope                = azurerm_resource_group.test.id
  policy_definition_id = azurerm_policy_definition.test.id
  description          = "Policy Assignment created via an Acceptance Test"
  display_name         = "Acceptance Test Run 220218071117643184"

  parameters = <<PARAMETERS
{
  "allowedLocations": {
    "value": [ "West Europe" ]
  }
}
PARAMETERS

}
