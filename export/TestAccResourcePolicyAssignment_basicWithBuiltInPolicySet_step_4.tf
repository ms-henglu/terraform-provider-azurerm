
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctest211112021034515785"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestvn-211112021034515785"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  address_space       = ["10.0.0.0/16"]
}


data "azurerm_policy_set_definition" "test" {
  display_name = "Audit machines with insecure password security settings"
}

resource "azurerm_resource_policy_assignment" "test" {
  name                 = "acctestpa-211112021034515785"
  resource_id          = azurerm_virtual_network.test.id
  policy_definition_id = data.azurerm_policy_set_definition.test.id
  location             = azurerm_resource_group.test.location

  identity {
    type = "SystemAssigned"
  }
}
