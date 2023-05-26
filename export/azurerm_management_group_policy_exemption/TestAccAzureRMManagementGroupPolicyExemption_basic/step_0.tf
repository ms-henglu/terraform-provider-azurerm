

provider "azurerm" {
  features {}
}


resource "azurerm_management_group" "test" {
  display_name = "Acceptance Test MgmtGroup 230526085637170483"
}


data "azurerm_policy_set_definition" "test" {
  display_name = "Audit machines with insecure password security settings"
}

resource "azurerm_management_group_policy_assignment" "test" {
  name                 = "acctestpol-mg-kzzsg"
  management_group_id  = azurerm_management_group.test.id
  policy_definition_id = data.azurerm_policy_set_definition.test.id
  location             = "West Europe"

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_management_group_policy_exemption" "test" {
  name                 = "acctest-exemption-230526085637170483"
  management_group_id  = azurerm_management_group.test.id
  policy_assignment_id = azurerm_management_group_policy_assignment.test.id
  exemption_category   = "Mitigated"
}
