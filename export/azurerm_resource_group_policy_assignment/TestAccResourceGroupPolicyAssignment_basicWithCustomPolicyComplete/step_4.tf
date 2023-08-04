
provider "azurerm" {
  features {}
}



resource "azurerm_resource_group" "test" {
  name     = "acctest230804030500418823"
  location = "West Europe"
}


resource "azurerm_policy_definition" "test" {
  name         = "acctestpol-230804030500418823"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "acctestpol-230804030500418823"

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
  name                 = "acctestpa-rg-230804030500418823"
  resource_group_id    = azurerm_resource_group.test.id
  policy_definition_id = azurerm_policy_definition.test.id
  description          = "This is a policy assignment from an acceptance test"
  display_name         = "AccTest Policy 230804030500418823"
  enforce              = false
  not_scopes = [
    format("%s/virtualMachines/testvm1", azurerm_resource_group.test.id)
  ]
  metadata = jsonencode({
    "category" : "Testing"
  })
}
