
provider "azurerm" {
  features {}
}



resource "azurerm_management_group" "test" {
  display_name = "Acceptance Test MgmtGroup 220114064459007380"
}


resource "azurerm_policy_definition" "test" {
  name                = "acctestpol-1l3cp"
  policy_type         = "Custom"
  mode                = "All"
  display_name        = "acctestpol-1l3cp"
  management_group_id = azurerm_management_group.test.group_id

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


resource "azurerm_management_group_policy_assignment" "test" {
  name                 = "acctestpol-1l3cp"
  management_group_id  = azurerm_management_group.test.id
  policy_definition_id = azurerm_policy_definition.test.id
  description          = "This is a policy assignment from an acceptance test"
  display_name         = "AccTest Policy 1l3cp"
  enforce              = false
  metadata = jsonencode({
    "category" : "Testing"
  })
}
