
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "test" {}

data "azurerm_policy_definition" "test" {
  display_name = "Allowed locations"
}

resource "azurerm_subscription_policy_assignment" "test" {
  name                 = "acctestpa-220324160652205403"
  subscription_id      = data.azurerm_subscription.test.id
  policy_definition_id = data.azurerm_policy_definition.test.id
  parameters = jsonencode({
    "listOfAllowedLocations" = {
      "value" = ["West Europe", "West US 2"]
    }
  })
}
