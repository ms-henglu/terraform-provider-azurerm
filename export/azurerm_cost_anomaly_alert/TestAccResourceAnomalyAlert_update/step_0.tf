
provider "azurerm" {
  features {}
}

resource "azurerm_cost_anomaly_alert" "test" {
  name            = "-acctest-240119024757246724"
  display_name    = "acctest 240119024757246724"
  email_subject   = "Hi"
  email_addresses = ["test@test.com", "test@hashicorp.developer"]
  message         = "Oops, cost anomaly"
}
