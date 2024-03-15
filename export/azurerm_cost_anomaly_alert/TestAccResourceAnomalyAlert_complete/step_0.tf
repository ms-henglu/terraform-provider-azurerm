
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "test" {}

resource "azurerm_cost_anomaly_alert" "test" {
  name            = "-acctest-240315122706886769"
  display_name    = "acctest 240315122706886769"
  subscription_id = data.azurerm_subscription.test.id
  email_subject   = "Hi"
  email_addresses = ["test@test.com", "test@hashicorp.developer"]
  message         = "Cost anomaly complete test"
}
