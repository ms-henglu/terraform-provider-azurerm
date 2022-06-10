

provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  display_name = "Acceptance Test MgmtGroup 220610093051304423"
}

data "azurerm_policy_definition" "test" {
  display_name = "Allowed locations"
}

resource "azurerm_management_group_policy_assignment" "test" {
  name                 = "acctestpol-West Europe"
  management_group_id  = azurerm_management_group.test.id
  policy_definition_id = data.azurerm_policy_definition.test.id
  parameters = jsonencode({
    "listOfAllowedLocations" = {
      "value" = ["West US 2"]
    }
  })
}


resource "azurerm_management_group_policy_remediation" "test" {
  name                 = "acctestremediation-nhujm"
  management_group_id  = azurerm_management_group.test.id
  policy_assignment_id = azurerm_management_group_policy_assignment.test.id
}
