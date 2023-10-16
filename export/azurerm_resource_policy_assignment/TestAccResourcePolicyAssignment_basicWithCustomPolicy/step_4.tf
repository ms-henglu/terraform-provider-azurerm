
provider "azurerm" {
  features {}
}



resource "azurerm_resource_group" "test" {
  name     = "acctest231016034510779473"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestvn-231016034510779473"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  address_space       = ["10.0.0.0/16"]
}


resource "azurerm_policy_definition" "test" {
  name         = "acctestpol-231016034510779473"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "acctestpol-231016034510779473"

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
  name                 = "acctestpa-231016034510779473"
  resource_id          = azurerm_virtual_network.test.id
  policy_definition_id = azurerm_policy_definition.test.id
}
