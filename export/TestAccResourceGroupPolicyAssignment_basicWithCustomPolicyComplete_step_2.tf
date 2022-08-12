
provider "azurerm" {
  features {}
}



resource "azurerm_resource_group" "test" {
  name     = "acctest220812015546213971"
  location = "West Europe"
}


resource "azurerm_policy_definition" "test" {
  name         = "acctestpol-220812015546213971"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "acctestpol-220812015546213971"

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
  name                 = "acctestpa-220812015546213971"
  resource_group_id    = azurerm_resource_group.test.id
  policy_definition_id = azurerm_policy_definition.test.id
}
