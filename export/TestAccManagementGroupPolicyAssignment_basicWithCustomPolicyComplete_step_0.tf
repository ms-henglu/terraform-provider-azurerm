
provider "azurerm" {
  features {}
}



resource "azurerm_management_group" "test" {
  display_name = "Acceptance Test MgmtGroup 220211044044008478"
}


resource "azurerm_policy_definition" "test" {
  name                = "acctestpol-12i7k"
  policy_type         = "Custom"
  mode                = "All"
  display_name        = "acctestpol-12i7k"
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
  name                 = "acctestpol-12i7k"
  management_group_id  = azurerm_management_group.test.id
  policy_definition_id = azurerm_policy_definition.test.id
  description          = "This is a policy assignment from an acceptance test"
  display_name         = "AccTest Policy 12i7k"
  enforce              = false
  metadata = jsonencode({
    "category" : "Testing"
  })
}
