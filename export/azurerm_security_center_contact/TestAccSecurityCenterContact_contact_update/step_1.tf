
provider "azurerm" {
  features {}
}

resource "azurerm_security_center_contact" "test" {
  name  = "test-account"
  email = "updated@example.com"
  phone = "+1-555-678-6789"

  alert_notifications = false
  alerts_to_admins    = false
}
