
provider "azurerm" {
  features {}
}

resource "azurerm_cost_anomaly_alert" "test" {
  name            = "-acctest-230915023155497739"
  display_name    = "acctest name update 230915023155497739"
  email_subject   = "Hi you!"
  email_addresses = ["tester@test.com", "test2@hashicorp.developer"]
  message         = "An updated cost anomaly for you"
}
