
provider "azurerm" {
  features {}
}



resource "azurerm_management_group" "test" {
  display_name = "Acceptance Test MgmtGroup 220520054416094701"
}


resource "azurerm_policy_definition" "test" {
  name                = "acctestpol-7zi11"
  policy_type         = "Custom"
  mode                = "All"
  display_name        = "acctestpol-7zi11"
  management_group_id = azurerm_management_group.test.id

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
  name                 = "acctestpol-7zi11"
  management_group_id  = azurerm_management_group.test.id
  policy_definition_id = azurerm_policy_definition.test.id
  description          = "This is a policy assignment from an acceptance test"
  display_name         = "AccTest Policy 7zi11"
  enforce              = false
  metadata = jsonencode({
    "category" : "Testing"
  })
}
