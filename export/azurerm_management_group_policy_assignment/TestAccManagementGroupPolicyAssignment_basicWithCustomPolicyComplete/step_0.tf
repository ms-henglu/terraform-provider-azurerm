
provider "azurerm" {
  features {}
}



resource "azurerm_management_group" "test" {
  display_name = "Acceptance Test MgmtGroup 240105064405521254"
}


resource "azurerm_policy_definition" "test" {
  name                = "acctestpol-mg-wv7di"
  policy_type         = "Custom"
  mode                = "All"
  display_name        = "acctestpol-mg-wv7di"
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
  name                 = "acctestpol-mg-wv7di"
  management_group_id  = azurerm_management_group.test.id
  policy_definition_id = azurerm_policy_definition.test.id
  description          = "This is a policy assignment from an acceptance test"
  display_name         = "AccTest Policy wv7di"
  enforce              = false
  metadata = jsonencode({
    "category" : "Testing"
  })
}
