
provider "azurerm" {
  features {

  }
}

resource "azurerm_security_center_subscription_pricing" "test" {
  tier          = "Free"
  resource_type = "CloudPosture"
}
