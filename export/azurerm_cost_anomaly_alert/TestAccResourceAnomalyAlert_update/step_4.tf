
provider "azurerm" {
  features {}
}

resource "azurerm_cost_anomaly_alert" "test" {
  name            = "-acctest-230804025712971494"
  display_name    = "acctest 230804025712971494"
  email_subject   = "Hi"
  email_addresses = ["test@test.com", "test@hashicorp.developer"]
  message         = "Oops, cost anomaly"
}
