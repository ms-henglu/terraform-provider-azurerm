

provider "azurerm" {
  features {}
}

data "azurerm_subscription" "test" {}

data "azurerm_policy_definition" "test" {
  display_name = "Allowed locations"
}

resource "azurerm_subscription_policy_assignment" "test" {
  name                 = "acctestpa-220712042628725777"
  subscription_id      = data.azurerm_subscription.test.id
  policy_definition_id = data.azurerm_policy_definition.test.id
  parameters = jsonencode({
    "listOfAllowedLocations" = {
      "value" = ["West Europe", "West US 2"]
    }
  })
}


resource "azurerm_subscription_policy_remediation" "test" {
  name                    = "acctestremediation-kbago"
  subscription_id         = data.azurerm_subscription.test.id
  policy_assignment_id    = azurerm_subscription_policy_assignment.test.id
  location_filters        = ["westus"]
  policy_definition_id    = data.azurerm_policy_definition.test.id
  resource_discovery_mode = "ReEvaluateCompliance"
}
