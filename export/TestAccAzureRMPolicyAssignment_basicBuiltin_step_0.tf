
provider "azurerm" {
  features {}
}

data "azurerm_policy_definition" "test" {
  display_name = "Allowed locations"
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211008044759281681"
  location = "West Europe"
}

resource "azurerm_policy_assignment" "test" {
  name                 = "acctestpa-211008044759281681"
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
