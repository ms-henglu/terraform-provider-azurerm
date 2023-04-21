
provider "azurerm" {
  features {}
}



resource "azurerm_management_group" "test" {
  display_name = "Acceptance Test MgmtGroup 230421022657041377"
}


resource "azurerm_policy_definition" "test" {
  name                = "acctestpol-mg-pkqrg"
  policy_type         = "Custom"
  mode                = "All"
  display_name        = "acctestpol-mg-pkqrg"
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


data "azurerm_policy_set_definition" "test" {
  display_name = "Audit machines with insecure password security settings"
}

resource "azurerm_management_group_policy_assignment" "test" {
  name                 = "acctestpol-mg-pkqrg"
  management_group_id  = azurerm_management_group.test.id
  policy_definition_id = data.azurerm_policy_set_definition.test.id
  metadata = jsonencode({
    "category" : "Testing"
  })

  overrides {
    value = "AuditIfNotExists"
    selectors {
      in = [data.azurerm_policy_set_definition.test.policy_definition_reference.0.reference_id]
    }
  }

  resource_selectors {
    name = "selected for policy"
    selectors {
      not_in = ["eastus"]
      kind   = "resourceLocation"
    }
  }
}
