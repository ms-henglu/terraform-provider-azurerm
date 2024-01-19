
provider "azurerm" {
  features {}
}


resource "azurerm_management_group" "test" {
  display_name = "Acceptance Test MgmtGroup 240119025606747981"
}


data "azurerm_policy_definition" "test" {
  display_name = "Allowed locations"
}

resource "azurerm_management_group_policy_assignment" "test" {
  name                 = "acctestpol-mg-l64vj"
  management_group_id  = azurerm_management_group.test.id
  policy_definition_id = data.azurerm_policy_definition.test.id

  non_compliance_message {
    content = "test"
  }

  parameters = jsonencode({
    "listOfAllowedLocations" = {
      "value" = ["West Europe"]
    }
  })
}
