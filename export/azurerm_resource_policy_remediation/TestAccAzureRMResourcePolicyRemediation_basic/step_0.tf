

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-policy-fnxpk"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestvn-fnxpk"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  address_space       = ["10.0.0.0/16"]
}

data "azurerm_policy_definition" "test" {
  display_name = "Allowed locations"
}

resource "azurerm_resource_policy_assignment" "test" {
  name                 = "acctestpa-res-fnxpk"
  resource_id          = azurerm_virtual_network.test.id
  policy_definition_id = data.azurerm_policy_definition.test.id
  parameters = jsonencode({
    "listOfAllowedLocations" = {
      "value" = [azurerm_resource_group.test.location, "West US 2"]
    }
  })
}


resource "azurerm_resource_policy_remediation" "test" {
  name                 = "acctestremediation-fnxpk"
  resource_id          = azurerm_virtual_network.test.id
  policy_assignment_id = azurerm_resource_policy_assignment.test.id
}
