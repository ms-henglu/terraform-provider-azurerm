
provider "azurerm" {
  features {}
}


data "azurerm_subscription" "test" {}

resource "azurerm_policy_definition" "test" {
  name         = "acctestpol-230810144025975904"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "acctestpol-230810144025975904"

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
  name                 = "acctestpa-sub-230810144025975904"
  subscription_id      = data.azurerm_subscription.test.id
  policy_definition_id = azurerm_policy_definition.test.id
  description          = "This is a policy assignment from an acceptance test"
  display_name         = "AccTest Policy 230810144025975904"
  enforce              = false
  not_scopes = [
    format("%s/resourceGroups/blah", data.azurerm_subscription.test.id)
  ]
  metadata = jsonencode({
    "category" : "Testing"
  })
}
