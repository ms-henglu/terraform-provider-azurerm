
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctest240119025606741653"
  location = "West Europe"
}


data "azurerm_policy_set_definition" "test" {
  display_name = "Audit machines with insecure password security settings"
}

resource "azurerm_resource_group_policy_assignment" "test" {
  name                 = "acctestpa-rg-240119025606741653"
  resource_group_id    = azurerm_resource_group.test.id
  policy_definition_id = data.azurerm_policy_set_definition.test.id
  location             = azurerm_resource_group.test.location

  non_compliance_message {
    content = "test"
  }

  identity {
    type = "SystemAssigned"
  }
}
