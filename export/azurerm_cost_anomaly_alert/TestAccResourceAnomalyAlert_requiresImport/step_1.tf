

provider "azurerm" {
  features {}
}

resource "azurerm_cost_anomaly_alert" "test" {
  name            = "-acctest-230922053909572802"
  display_name    = "acctest 230922053909572802"
  email_subject   = "Hi"
  email_addresses = ["test@test.com", "test@hashicorp.developer"]
  message         = "Oops, cost anomaly"
}


resource "azurerm_cost_anomaly_alert" "import" {
  name            = azurerm_cost_anomaly_alert.test.name
  display_name    = azurerm_cost_anomaly_alert.test.display_name
  email_subject   = azurerm_cost_anomaly_alert.test.email_subject
  email_addresses = azurerm_cost_anomaly_alert.test.email_addresses
  message         = azurerm_cost_anomaly_alert.test.message
}
