
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "current" {}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220726014810963344"
  location = "West Europe"
}

resource "azurerm_eventgrid_system_topic" "test" {
  name                   = "acctestEGST220726014810963344"
  location               = "Global"
  resource_group_name    = azurerm_resource_group.test.name
  source_arm_resource_id = format("/subscriptions/%s", data.azurerm_subscription.current.subscription_id)
  topic_type             = "Microsoft.PolicyInsights.PolicyStates"

  tags = {
    "Foo" = "Bar"
  }
}
