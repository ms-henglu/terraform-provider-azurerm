
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctest231016034510771609"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestvn-231016034510771609"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  address_space       = ["10.0.0.0/16"]
}


data "azurerm_policy_definition" "test" {
  display_name = "Allowed locations"
}

resource "azurerm_resource_policy_assignment" "test" {
  name                 = "acctestpa-231016034510771609"
  resource_id          = azurerm_virtual_network.test.id
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
