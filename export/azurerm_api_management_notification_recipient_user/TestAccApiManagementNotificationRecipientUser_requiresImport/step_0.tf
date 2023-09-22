

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230922060507053458"
  location = "West Europe"
}

resource "azurerm_api_management" "test" {
  name                = "acctestAM-230922060507053458"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  publisher_name      = "pub1"
  publisher_email     = "pub1@email.com"

  sku_name = "Developer_1"
}


resource "azurerm_api_management_user" "test" {
  user_id             = "123"
  api_management_name = azurerm_api_management.test.name
  resource_group_name = azurerm_resource_group.test.name
  first_name          = "Example"
  last_name           = "User"
  email               = "foo@bar.com"
  state               = "active"
}

resource "azurerm_api_management_notification_recipient_user" "test" {
  api_management_id = azurerm_api_management.test.id
  notification_type = "AccountClosedPublisher"
  user_id           = azurerm_api_management_user.test.user_id
}
