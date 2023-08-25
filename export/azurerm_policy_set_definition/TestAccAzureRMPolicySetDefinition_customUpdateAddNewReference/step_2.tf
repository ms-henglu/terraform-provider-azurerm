

provider "azurerm" {
  features {}
}

resource "azurerm_policy_definition" "test" {
  name         = "acctestpol-230825025109523333"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "acctestpol-230825025109523333"

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


data "azurerm_policy_definition" "allowed_resource_types" {
  display_name = "Allowed resource types"
}

resource "azurerm_policy_set_definition" "test" {
  name         = "acctestPolSet-230825025109523333"
  policy_type  = "Custom"
  display_name = "acctestPolSet-display-230825025109523333"

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

  policy_definition_reference {
    policy_definition_id = azurerm_policy_definition.test.id
    parameter_values     = <<VALUES
	{
      "allowedLocations": {"value": "[parameters('allowedLocations')]"}
    }
VALUES
  }

  policy_definition_reference {
    policy_definition_id = data.azurerm_policy_definition.allowed_resource_types.id
    parameter_values     = <<VALUES
	{
      "listOfResourceTypesAllowed": {"value": ["Microsoft.Compute/virtualMachines"]}
    }
VALUES
  }
}
