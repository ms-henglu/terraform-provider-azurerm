

provider "azurerm" {
  features {}
}

resource "azurerm_policy_set_definition" "test" {
  name         = "acctestpolset-230825025109521327"
  policy_type  = "Custom"
  display_name = "acctestpolset-230825025109521327"

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
    policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/e765b5de-1225-4ba3-bd56-1ac6695af988"
    parameter_values     = <<VALUES
	{
      "listOfAllowedLocations": {"value": "[parameters('allowedLocations')]"}
    }
VALUES
  }
}


resource "azurerm_policy_set_definition" "import" {
  name         = azurerm_policy_set_definition.test.name
  policy_type  = azurerm_policy_set_definition.test.policy_type
  display_name = azurerm_policy_set_definition.test.display_name
  parameters   = azurerm_policy_set_definition.test.parameters

  policy_definition_reference {
    policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/e765b5de-1225-4ba3-bd56-1ac6695af988"
    parameter_values     = <<VALUES
	{
      "listOfAllowedLocations": {"value": "[parameters('allowedLocations')]"}
    }
VALUES
  }
}
