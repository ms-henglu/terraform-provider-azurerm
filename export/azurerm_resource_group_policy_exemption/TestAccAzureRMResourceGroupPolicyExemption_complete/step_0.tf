

provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctest221021031605022131"
  location = "West Europe"
}


data "azurerm_policy_set_definition" "test" {
  display_name = "Audit machines with insecure password security settings"
}

resource "azurerm_resource_group_policy_assignment" "test" {
  name                 = "acctestpa-rg-221021031605022131"
  resource_group_id    = azurerm_resource_group.test.id
  policy_definition_id = data.azurerm_policy_set_definition.test.id
  location             = azurerm_resource_group.test.location

  identity {
    type = "SystemAssigned"
  }
}


resource "azurerm_resource_group_policy_exemption" "test" {
  name                 = "acctest-exemption-221021031605022131"
  resource_group_id    = azurerm_resource_group.test.id
  policy_assignment_id = azurerm_resource_group_policy_assignment.test.id
  exemption_category   = "Waiver"

  display_name = "Policy Exemption for acceptance test"
  description  = "Policy Exemption created in an acceptance test"
  expires_on   = "2022-10-22T03:16:05Z"

  metadata = <<METADATA
    {
        "foo": "bar"
    }
METADATA
}
