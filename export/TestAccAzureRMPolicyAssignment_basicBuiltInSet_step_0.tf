
provider "azurerm" {
  features {}
}

data "azurerm_policy_set_definition" "test" {
  display_name = "Audit machines with insecure password security settings"
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220124125453592312"
  location = "West Europe"
}

resource "azurerm_policy_assignment" "test" {
  name                 = "acctestpa-220124125453592312"
  location             = azurerm_resource_group.test.location
  scope                = azurerm_resource_group.test.id
  policy_definition_id = data.azurerm_policy_set_definition.test.id

  identity {
    type = "SystemAssigned"
  }
}
