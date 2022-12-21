

provider "azurerm" {
  features {}
}



resource "azurerm_management_group" "test" {
  display_name = "Acceptance Test MgmtGroup 221221204656156110"
}


resource "azurerm_policy_definition" "test" {
  name                = "acctestpol-mg-1uusn"
  policy_type         = "Custom"
  mode                = "All"
  display_name        = "acctestpol-mg-1uusn"
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
  name                 = "acctestpol-mg-1uusn"
  management_group_id  = azurerm_management_group.test.id
  policy_definition_id = azurerm_policy_definition.test.id
}


resource "azurerm_management_group_policy_assignment" "import" {
  name                 = azurerm_management_group_policy_assignment.test.name
  management_group_id  = azurerm_management_group_policy_assignment.test.management_group_id
  policy_definition_id = azurerm_management_group_policy_assignment.test.policy_definition_id
}
