
provider "azurerm" {
  features {}
}



resource "azurerm_management_group" "test" {
  display_name = "Acceptance Test MgmtGroup 220211131015735365"
}


resource "azurerm_policy_definition" "test" {
  name                = "acctestpol-t1349"
  policy_type         = "Custom"
  mode                = "All"
  display_name        = "acctestpol-t1349"
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
  name                 = "acctestpol-t1349"
  management_group_id  = azurerm_management_group.test.id
  policy_definition_id = azurerm_policy_definition.test.id
  description          = "This is a policy assignment from an acceptance test"
  display_name         = "AccTest Policy t1349"
  enforce              = false
  metadata = jsonencode({
    "category" : "Testing"
  })
}
