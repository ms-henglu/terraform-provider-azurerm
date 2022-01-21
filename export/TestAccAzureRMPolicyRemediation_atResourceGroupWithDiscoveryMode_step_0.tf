
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-policy-cgp2w"
  location = "West Europe"
}

resource "azurerm_policy_definition" "test" {
  name         = "acctestDef-cgp2w"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "my-policy-definition"

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

resource "azurerm_policy_assignment" "test" {
  name                 = "acctestAssign-cgp2w"
  scope                = azurerm_resource_group.test.id
  policy_definition_id = azurerm_policy_definition.test.id
  description          = "Policy Assignment created via an Acceptance Test"
  display_name         = "My Example Policy Assignment"

  parameters = <<PARAMETERS
{
  "allowedLocations": {
    "value": [ "West Europe" ]
  }
}
PARAMETERS
}

resource "azurerm_policy_remediation" "test" {
  name                 = "acctestremediation-cgp2w"
  scope                = azurerm_policy_assignment.test.scope
  policy_assignment_id = azurerm_policy_assignment.test.id

  resource_discovery_mode = "ReEvaluateCompliance"
}
