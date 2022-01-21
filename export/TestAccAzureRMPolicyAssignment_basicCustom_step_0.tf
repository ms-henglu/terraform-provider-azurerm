
provider "azurerm" {
  features {}
}

resource "azurerm_policy_definition" "test" {
  name         = "acctestpol-220121044834096432"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "acctestpol-220121044834096432"

  policy_rule = <<POLICY_RULE
	{
    "if": {
      "not": {
        "field": "location",
        "equals": "West Europe"
      }
    },
    "then": {
      "effect": "audit"
    }
  }
POLICY_RULE

}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220121044834096432"
  location = "West Europe"
}

resource "azurerm_policy_assignment" "test" {
  name                 = "acctestpa-220121044834096432"
  scope                = azurerm_resource_group.test.id
  policy_definition_id = azurerm_policy_definition.test.id

  metadata = <<METADATA
  {
    "category": "General"
  }
METADATA

}
