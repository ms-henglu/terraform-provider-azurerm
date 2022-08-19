

provider "azurerm" {
  features {}
}

data "azurerm_subscription" "test" {}

data "azurerm_policy_set_definition" "test" {
  display_name = "Audit machines with insecure password security settings"
}

resource "azurerm_subscription_policy_assignment" "test" {
  name                 = "acctestpa-220819165544838252"
  subscription_id      = data.azurerm_subscription.test.id
  policy_definition_id = data.azurerm_policy_set_definition.test.id
  location             = "West Europe"

  identity {
    type = "SystemAssigned"
  }
}


resource "azurerm_subscription_policy_exemption" "test" {
  name                 = "acctest-exemption-220819165544838252"
  subscription_id      = data.azurerm_subscription.test.id
  policy_assignment_id = azurerm_subscription_policy_assignment.test.id
  exemption_category   = "Waiver"

  display_name = "Policy Exemption for acceptance test"
  description  = "Policy Exemption created in an acceptance test"
  expires_on   = "2022-08-20T16:55:44Z"

  metadata = <<METADATA
    {
        "foo": "bar"
    }
METADATA
}
