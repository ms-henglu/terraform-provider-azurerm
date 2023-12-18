

provider "azurerm" {
  features {}
}

resource "azurerm_policy_definition" "test" {
  name         = "acctestpol-231218072334467459"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "acctestpol-231218072334467459"

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


resource "azurerm_policy_set_definition" "test" {
  name         = "acctestPolSet-231218072334467459"
  policy_type  = "Custom"
  display_name = "acctestPolSet-display-231218072334467459"

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
    policy_group_names   = ["group-1", "group-2", "group-3"]
  }

  policy_definition_group {
    name = "redundant"
  }

  policy_definition_group {
    name         = "group-1"
    display_name = "Group-Display-1"
    category     = "My Access Control"
    description  = "Controls accesses"
  }

  policy_definition_group {
    name         = "group-2"
    display_name = "group-display-2"
    category     = "My Security Control"
    description  = "Controls security"
  }

  policy_definition_group {
    name         = "group-3"
    display_name = "group-display-3"
    category     = "Category-3"
    description  = "Newly added group 3"
  }
}
