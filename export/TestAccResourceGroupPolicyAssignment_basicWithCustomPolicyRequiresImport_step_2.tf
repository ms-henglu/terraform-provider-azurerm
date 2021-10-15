

provider "azurerm" {
  features {}
}



resource "azurerm_resource_group" "test" {
  name     = "acctest211015014621604040"
  location = "West Europe"
}


resource "azurerm_policy_definition" "test" {
  name         = "acctestpol-211015014621604040"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "acctestpol-211015014621604040"

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
  name                 = "acctestpa-211015014621604040"
  resource_group_id    = azurerm_resource_group.test.id
  policy_definition_id = azurerm_policy_definition.test.id
}


resource "azurerm_resource_group_policy_assignment" "import" {
  name                 = azurerm_resource_group_policy_assignment.test.name
  resource_group_id    = azurerm_resource_group_policy_assignment.test.resource_group_id
  policy_definition_id = azurerm_resource_group_policy_assignment.test.policy_definition_id
}
