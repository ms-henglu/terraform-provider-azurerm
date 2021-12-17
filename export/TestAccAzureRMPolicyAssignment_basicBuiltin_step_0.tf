
provider "azurerm" {
  features {}
}

data "azurerm_policy_definition" "test" {
  display_name = "Allowed locations"
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211217075640689687"
  location = "West Europe"
}

resource "azurerm_policy_assignment" "test" {
  name                 = "acctestpa-211217075640689687"
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
