

provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctest230407023901904001"
  location = "West Europe"
}


data "azurerm_policy_set_definition" "test" {
  display_name = "Audit machines with insecure password security settings"
}

resource "azurerm_resource_group_policy_assignment" "test" {
  name                 = "acctestpa-rg-230407023901904001"
  resource_group_id    = azurerm_resource_group.test.id
  policy_definition_id = data.azurerm_policy_set_definition.test.id
  location             = azurerm_resource_group.test.location

  identity {
    type = "SystemAssigned"
  }
}


resource "azurerm_resource_group_policy_exemption" "test" {
  name                 = "acctest-exemption-230407023901904001"
  resource_group_id    = azurerm_resource_group.test.id
  policy_assignment_id = azurerm_resource_group_policy_assignment.test.id
  exemption_category   = "Waiver"

  display_name = "Policy Exemption for acceptance test"
  description  = "Policy Exemption created in an acceptance test"
  expires_on   = "2023-04-08T02:39:01Z"

  metadata = <<METADATA
    {
        "foo": "bar"
    }
METADATA
}
