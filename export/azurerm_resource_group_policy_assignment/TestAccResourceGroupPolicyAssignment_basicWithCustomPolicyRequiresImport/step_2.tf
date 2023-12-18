

provider "azurerm" {
  features {}
}



resource "azurerm_resource_group" "test" {
  name     = "acctest231218072334458465"
  location = "West Europe"
}


resource "azurerm_policy_definition" "test" {
  name         = "acctestpol-231218072334458465"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "acctestpol-231218072334458465"

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


resource "azurerm_resource_group_policy_assignment" "test" {
  name                 = "acctestpa-rg-231218072334458465"
  resource_group_id    = azurerm_resource_group.test.id
  policy_definition_id = azurerm_policy_definition.test.id
}


resource "azurerm_resource_group_policy_assignment" "import" {
  name                 = azurerm_resource_group_policy_assignment.test.name
  resource_group_id    = azurerm_resource_group_policy_assignment.test.resource_group_id
  policy_definition_id = azurerm_resource_group_policy_assignment.test.policy_definition_id
}
