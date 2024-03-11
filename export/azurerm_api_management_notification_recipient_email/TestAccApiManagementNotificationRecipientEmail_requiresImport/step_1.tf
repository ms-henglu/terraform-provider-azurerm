


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240311031231508128"
  location = "West Europe"
}

resource "azurerm_api_management" "test" {
  name                = "acctestAM-240311031231508128"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  publisher_name      = "pub1"
  publisher_email     = "pub1@email.com"

  sku_name = "Developer_1"
}

resource "azurerm_api_management_notification_recipient_email" "test" {
  api_management_id = azurerm_api_management.test.id
  notification_type = "AccountClosedPublisher"
  email             = "foo@bar.com"
}


resource "azurerm_api_management_notification_recipient_email" "import" {
  api_management_id = azurerm_api_management.test.id
  notification_type = azurerm_api_management_notification_recipient_email.test.notification_type
  email             = azurerm_api_management_notification_recipient_email.test.email
}
