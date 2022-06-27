
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "current" {}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-eg-220627122639924347"
  location = "West Europe"
}

resource "azurerm_eventgrid_system_topic" "test" {
  name                   = "acctestEGST2206271247"
  location               = "Global"
  resource_group_name    = azurerm_resource_group.test.name
  source_arm_resource_id = format("/subscriptions/%s", data.azurerm_subscription.current.subscription_id)
  topic_type             = "Microsoft.PolicyInsights.PolicyStates"

  tags = {
    "Foo" = "Bar"
  }
}
