

provider "azurerm" {
  features {}
}

resource "azurerm_policy_definition" "test" {
  name         = "acctestpol-240119025606766275"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "acctestpol-240119025606766275"

  policy_rule = <<POLICY_RULE
	{
    "if": {
      "not": {
        "field": "location",
        "equals": "West Europe"
      }
    },
    "then": {
      "effect": "deny"
    }
  }
POLICY_RULE
}


resource "azurerm_policy_set_definition" "test" {
  name         = "acctestPolSet-240119025606766275"
  policy_type  = "Custom"
  display_name = "acctestPolSet-display-240119025606766275"

  policy_definition_reference {
    policy_definition_id = azurerm_policy_definition.test.id
  }
}
