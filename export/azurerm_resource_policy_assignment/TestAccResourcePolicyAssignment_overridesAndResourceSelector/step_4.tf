
provider "azurerm" {
  features {}
}



resource "azurerm_resource_group" "test" {
  name     = "acctest231218072334462341"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestvn-231218072334462341"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  address_space       = ["10.0.0.0/16"]
}


resource "azurerm_policy_definition" "test" {
  name         = "acctestpol-231218072334462341"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "acctestpol-231218072334462341"

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


data "azurerm_policy_set_definition" "test" {
  display_name = "Audit machines with insecure password security settings"
}

resource "azurerm_resource_policy_assignment" "test" {
  name                 = "acctestpa-231218072334462341"
  resource_id          = azurerm_virtual_network.test.id
  policy_definition_id = data.azurerm_policy_set_definition.test.id
  metadata = jsonencode({
    "category" : "Testing"
  })

  overrides {
    value = "Disabled"
    selectors {
      in = [data.azurerm_policy_set_definition.test.policy_definition_reference.0.reference_id]
    }
  }

  resource_selectors {
    selectors {
      not_in = ["eastus", "westus"]
      kind   = "resourceLocation"
    }
  }
}
