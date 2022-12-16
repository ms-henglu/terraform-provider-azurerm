
provider "azurerm" {
  features {}
}



resource "azurerm_resource_group" "test" {
  name     = "acctest221216014004373260"
  location = "West Europe"
}


resource "azurerm_policy_definition" "test" {
  name         = "acctestpol-221216014004373260"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "acctestpol-221216014004373260"

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
  name                 = "acctestpa-rg-221216014004373260"
  resource_group_id    = azurerm_resource_group.test.id
  policy_definition_id = azurerm_policy_definition.test.id
}
