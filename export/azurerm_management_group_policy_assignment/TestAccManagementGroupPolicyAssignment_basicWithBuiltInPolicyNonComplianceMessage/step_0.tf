
provider "azurerm" {
  features {}
}


resource "azurerm_management_group" "test" {
  display_name = "Acceptance Test MgmtGroup 230728030419771231"
}


data "azurerm_policy_definition" "test" {
  display_name = "Allowed locations"
}

resource "azurerm_management_group_policy_assignment" "test" {
  name                 = "acctestpol-mg-p47rd"
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
