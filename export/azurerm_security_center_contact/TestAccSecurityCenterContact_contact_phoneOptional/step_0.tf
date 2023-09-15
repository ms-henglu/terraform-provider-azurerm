
provider "azurerm" {
  features {}
}

resource "azurerm_security_center_contact" "test" {
  name  = "test-account"
  email = "basic@example.com"

  alert_notifications = true
  alerts_to_admins    = true
}
