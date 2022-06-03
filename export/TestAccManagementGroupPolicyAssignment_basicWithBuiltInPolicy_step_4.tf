
provider "azurerm" {
  features {}
}


resource "azurerm_management_group" "test" {
  display_name = "Acceptance Test MgmtGroup 220603005148737822"
}


data "azurerm_policy_definition" "test" {
  display_name = "Allowed locations"
}

resource "azurerm_management_group_policy_assignment" "test" {
  name                 = "acctestpol-9cbyx"
  management_group_id  = azurerm_management_group.test.id
  policy_definition_id = data.azurerm_policy_definition.test.id
  parameters = jsonencode({
    "listOfAllowedLocations" = {
      "value" = ["West Europe"]
    }
  })
}
