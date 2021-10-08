
provider "azurerm" {
  features {}
}



resource "azurerm_management_group" "test" {
  display_name = "Acceptance Test MgmtGroup 211008044759275886"
}


resource "azurerm_policy_definition" "test" {
  name                = "acctestpol-8vtnm"
  policy_type         = "Custom"
  mode                = "All"
  display_name        = "acctestpol-8vtnm"
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
  name                 = "acctestpol-8vtnm"
  management_group_id  = azurerm_management_group.test.id
  policy_definition_id = azurerm_policy_definition.test.id
}
