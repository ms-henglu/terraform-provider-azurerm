

provider "azurerm" {
  features {}
}



resource "azurerm_resource_group" "test" {
  name     = "acctest210825045112138566"
  location = "West Europe"
}


resource "azurerm_policy_definition" "test" {
  name         = "acctestpol-210825045112138566"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "acctestpol-210825045112138566"

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
  name                 = "acctestpa-210825045112138566"
  resource_group_id    = azurerm_resource_group.test.id
  policy_definition_id = azurerm_policy_definition.test.id
}


resource "azurerm_resource_group_policy_assignment" "import" {
  name                 = azurerm_resource_group_policy_assignment.test.name
  resource_group_id    = azurerm_resource_group_policy_assignment.test.resource_group_id
  policy_definition_id = azurerm_resource_group_policy_assignment.test.policy_definition_id
}
