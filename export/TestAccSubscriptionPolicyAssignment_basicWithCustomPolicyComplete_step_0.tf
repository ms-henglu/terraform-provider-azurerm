
provider "azurerm" {
  features {}
}


data "azurerm_subscription" "test" {}

resource "azurerm_policy_definition" "test" {
  name         = "acctestpol-220729033117027811"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "acctestpol-220729033117027811"

  policy_rule = <<POLICY_RULE
	{
    "if": {
      "not": {
        "field": "name",
        "equals": "bob"
      }
    },
    "then": {
      "effect": "audit"
    }
  }
POLICY_RULE
}


resource "azurerm_subscription_policy_assignment" "test" {
  name                 = "acctestpa-220729033117027811"
  subscription_id      = data.azurerm_subscription.test.id
  policy_definition_id = azurerm_policy_definition.test.id
  description          = "This is a policy assignment from an acceptance test"
  display_name         = "AccTest Policy 220729033117027811"
  enforce              = false
  not_scopes = [
    format("%s/resourceGroups/blah", data.azurerm_subscription.test.id)
  ]
  metadata = jsonencode({
    "category" : "Testing"
  })
}
