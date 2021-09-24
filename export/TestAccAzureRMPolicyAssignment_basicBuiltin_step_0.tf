
provider "azurerm" {
  features {}
}

data "azurerm_policy_definition" "test" {
  display_name = "Allowed locations"
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210924004700072099"
  location = "West Europe"
}

resource "azurerm_policy_assignment" "test" {
  name                 = "acctestpa-210924004700072099"
  scope                = azurerm_resource_group.test.id
  policy_definition_id = data.azurerm_policy_definition.test.id
  parameters           = <<PARAMETERS
{
  "listOfAllowedLocations": {
    "value": [ "West Europe" ]
  }
}
PARAMETERS
}
