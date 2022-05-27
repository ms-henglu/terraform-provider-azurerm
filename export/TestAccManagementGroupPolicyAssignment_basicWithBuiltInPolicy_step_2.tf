
provider "azurerm" {
  features {}
}


resource "azurerm_management_group" "test" {
  display_name = "Acceptance Test MgmtGroup 220527034525844052"
}


data "azurerm_policy_definition" "test" {
  display_name = "Allowed locations"
}

resource "azurerm_management_group_policy_assignment" "test" {
  name                 = "acctestpol-j0cto"
  management_group_id  = azurerm_management_group.test.id
  policy_definition_id = data.azurerm_policy_definition.test.id
  parameters = jsonencode({
    "listOfAllowedLocations" = {
      "value" = ["West Europe", "West US 2"]
    }
  })
}
