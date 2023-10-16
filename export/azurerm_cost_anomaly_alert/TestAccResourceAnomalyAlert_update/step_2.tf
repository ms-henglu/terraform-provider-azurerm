
provider "azurerm" {
  features {}
}

resource "azurerm_cost_anomaly_alert" "test" {
  name            = "-acctest-231016033652962320"
  display_name    = "acctest name update 231016033652962320"
  email_subject   = "Hi you!"
  email_addresses = ["tester@test.com", "test2@hashicorp.developer"]
  message         = "An updated cost anomaly for you"
}
