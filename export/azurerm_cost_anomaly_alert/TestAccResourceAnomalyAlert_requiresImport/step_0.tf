
provider "azurerm" {
  features {}
}

resource "azurerm_cost_anomaly_alert" "test" {
  name            = "-acctest-240119024757245262"
  display_name    = "acctest 240119024757245262"
  email_subject   = "Hi"
  email_addresses = ["test@test.com", "test@hashicorp.developer"]
  message         = "Oops, cost anomaly"
}
