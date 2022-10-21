

provider "azurerm" {
  features {}
}


resource "azurerm_management_group" "test" {
  display_name = "Acceptance Test MgmtGroup 221021034436774571"
}


data "azurerm_policy_set_definition" "test" {
  display_name = "Audit machines with insecure password security settings"
}

resource "azurerm_management_group_policy_assignment" "test" {
  name                 = "acctestpol-mg-mof96"
  management_group_id  = azurerm_management_group.test.id
  policy_definition_id = data.azurerm_policy_set_definition.test.id
  location             = "West Europe"

  identity {
    type = "SystemAssigned"
  }
}


resource "azurerm_management_group_policy_exemption" "test" {
  name                 = "acctest-exemption-221021034436774571"
  management_group_id  = azurerm_management_group.test.id
  policy_assignment_id = azurerm_management_group_policy_assignment.test.id
  exemption_category   = "Waiver"

  display_name = "Policy Exemption for acceptance test"
  description  = "Policy Exemption created in an acceptance test"
  expires_on   = "2022-10-22T03:44:36Z"

  metadata = <<METADATA
    {
        "foo": "bar"
    }
METADATA
}
