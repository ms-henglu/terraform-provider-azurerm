
provider "azurerm" {
  features {}
}

resource "azurerm_security_center_contact" "test" {
  name  = "test-account"
  email = "update@example.com"
  phone = "+1-555-555-5555"

  alert_notifications = true
  alerts_to_admins    = true
}
