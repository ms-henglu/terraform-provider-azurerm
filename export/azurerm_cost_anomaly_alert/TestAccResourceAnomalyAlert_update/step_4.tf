
provider "azurerm" {
  features {}
}

resource "azurerm_cost_anomaly_alert" "test" {
  name            = "-acctest-230512010452427477"
  display_name    = "acctest 230512010452427477"
  email_subject   = "Hi"
  email_addresses = ["test@test.com", "test@hashicorp.developer"]
  message         = "Oops, cost anomaly"
}
