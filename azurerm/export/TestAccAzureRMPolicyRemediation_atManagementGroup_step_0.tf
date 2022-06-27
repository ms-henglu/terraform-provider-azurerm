
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  display_name = "acctest-policy-wlwj0"
}

resource "azurerm_policy_definition" "test" {
  name                = "acctestDef-wlwj0"
  policy_type         = "Custom"
  mode                = "All"
  display_name        = "my-policy-definition"
  management_group_id = azurerm_management_group.test.group_id

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
  name = "acctestAssign-wlwj0"
  #   scope                = azurerm_resource_group.test.id
  #   scope                = data.azurerm_subscription.current.id
  scope = azurerm_management_group.test.id
  # scope                = azurerm_virtual_machine.main.id
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
  name                 = "acctestremediation-wlwj0"
  scope                = azurerm_policy_assignment.test.scope
  policy_assignment_id = azurerm_policy_assignment.test.id
}
