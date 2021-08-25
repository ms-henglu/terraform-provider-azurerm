

provider "azurerm" {
  features {}
}

resource "azurerm_policy_definition" "test" {
  name         = "acctestpol-210825045112147603"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "acctestpol-210825045112147603"

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
  name     = "acctestRG-210825045112147603"
  location = "West Europe"
}

resource "azurerm_policy_assignment" "test" {
  name                 = "acctestpa-210825045112147603"
  scope                = azurerm_resource_group.test.id
  policy_definition_id = azurerm_policy_definition.test.id

  metadata = <<METADATA
  {
    "category": "General"
  }
METADATA

}


resource "azurerm_policy_assignment" "import" {
  name                 = azurerm_policy_assignment.test.name
  scope                = azurerm_policy_assignment.test.scope
  policy_definition_id = azurerm_policy_assignment.test.policy_definition_id
}
