

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-policy-ifl2f"
  location = "West Europe"
}

resource "azurerm_policy_definition" "test" {
  name         = "acctestDef-ifl2f"
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

resource "azurerm_resource_group_policy_assignment" "test" {
  name                 = "acctestpa-rg-ifl2f"
  resource_group_id    = azurerm_resource_group.test.id
  policy_definition_id = azurerm_policy_definition.test.id

  non_compliance_message {
    content = "test"
  }

  parameters = jsonencode({
    "allowedLocations" = {
      "value" = [azurerm_resource_group.test.location]
    }
  })
}


resource "azurerm_resource_group_policy_remediation" "test" {
  name                 = "acctestremediation-ifl2f"
  resource_group_id    = azurerm_resource_group_policy_assignment.test.resource_group_id
  policy_assignment_id = azurerm_resource_group_policy_assignment.test.id
}
