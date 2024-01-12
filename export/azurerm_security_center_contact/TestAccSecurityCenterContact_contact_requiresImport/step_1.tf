

provider "azurerm" {
  features {}
}

resource "azurerm_security_center_contact" "test" {
  name  = "test-account"
  email = "email1@example.com"
  phone = "+1-555-555-5555"

  alert_notifications = true
  alerts_to_admins    = true
}


resource "azurerm_security_center_contact" "import" {
  name  = azurerm_security_center_contact.test.name
  email = azurerm_security_center_contact.test.email
  phone = azurerm_security_center_contact.test.phone

  alert_notifications = azurerm_security_center_contact.test.alert_notifications
  alerts_to_admins    = azurerm_security_center_contact.test.alerts_to_admins
}
