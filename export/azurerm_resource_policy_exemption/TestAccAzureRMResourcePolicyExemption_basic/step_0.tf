

provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctest230825025109515533"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestvn-230825025109515533"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  address_space       = ["10.0.0.0/16"]
}


data "azurerm_policy_set_definition" "test" {
  display_name = "Audit machines with insecure password security settings"
}

resource "azurerm_resource_policy_assignment" "test" {
  name                 = "acctestpa-230825025109515533"
  resource_id          = azurerm_virtual_network.test.id
  policy_definition_id = data.azurerm_policy_set_definition.test.id
  location             = azurerm_resource_group.test.location

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_resource_policy_exemption" "test" {
  name                 = "acctest-exemption-230825025109515533"
  resource_id          = azurerm_resource_policy_assignment.test.resource_id
  policy_assignment_id = azurerm_resource_policy_assignment.test.id
  exemption_category   = "Mitigated"
}
