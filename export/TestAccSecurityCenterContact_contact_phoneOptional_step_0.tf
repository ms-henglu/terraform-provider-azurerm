
provider "azurerm" {
  features {}
}

resource "azurerm_security_center_contact" "test" {
  email = "basic@example.com"

  alert_notifications = true
  alerts_to_admins    = true
}
