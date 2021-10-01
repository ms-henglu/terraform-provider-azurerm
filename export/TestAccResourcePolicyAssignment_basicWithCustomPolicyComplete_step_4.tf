
provider "azurerm" {
  features {}
}



resource "azurerm_resource_group" "test" {
  name     = "acctest211001021106966705"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestvn-211001021106966705"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  address_space       = ["10.0.0.0/16"]
}


resource "azurerm_policy_definition" "test" {
  name         = "acctestpol-211001021106966705"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "acctestpol-211001021106966705"

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


resource "azurerm_resource_policy_assignment" "test" {
  name                 = "acctestpa-211001021106966705"
  resource_id          = azurerm_virtual_network.test.id
  policy_definition_id = azurerm_policy_definition.test.id
  description          = "This is a policy assignment from an acceptance test"
  display_name         = "AccTest Policy 211001021106966705"
  enforce              = false
  not_scopes = [
    format("%s/subnets/subnet1", azurerm_virtual_network.test.id)
  ]
  metadata = jsonencode({
    "category" : "Testing"
  })
}
