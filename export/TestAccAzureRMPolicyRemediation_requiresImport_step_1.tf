

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-policy-w2y1y"
  location = "West Europe"
}

resource "azurerm_policy_definition" "test" {
  name         = "acctestDef-w2y1y"
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
  name                 = "acctestAssign-w2y1y"
  scope                = azurerm_resource_group.test.id
  policy_definition_id = azurerm_policy_definition.test.id
  description          = "Policy Assignment created via an Acceptance Test"
  display_name         = "acctestAssign-w2y1y"

  parameters = <<PARAMETERS
{
  "allowedLocations": {
    "value": [ "West Europe" ]
  }
}
PARAMETERS
}

resource "azurerm_policy_remediation" "test" {
  name                 = "acctestremediation-w2y1y"
  scope                = azurerm_policy_assignment.test.scope
  policy_assignment_id = azurerm_policy_assignment.test.id
}


resource "azurerm_policy_remediation" "import" {
  name                 = azurerm_policy_remediation.test.name
  scope                = azurerm_policy_remediation.test.scope
  policy_assignment_id = azurerm_policy_remediation.test.policy_assignment_id
}
