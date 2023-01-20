
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctest230120052516599261"
  location = "West Europe"
}


data "azurerm_policy_definition" "test" {
  display_name = "Allowed locations"
}

resource "azurerm_resource_group_policy_assignment" "test" {
  name                 = "acctestpa-rg-230120052516599261"
  resource_group_id    = azurerm_resource_group.test.id
  policy_definition_id = data.azurerm_policy_definition.test.id

  non_compliance_message {
    content = "test"
  }

  parameters = jsonencode({
    "listOfAllowedLocations" = {
      "value" = [azurerm_resource_group.test.location]
    }
  })
}
