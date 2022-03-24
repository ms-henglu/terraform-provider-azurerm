
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220324161018534282"
  location = "West Europe"
}

resource "azurerm_app_service_plan" "test" {
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  name                = "acctestRG-220324161018534282"
  kind                = "Linux"
  reserved            = true

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service" "test" {
  name                = "acctestRG-220324161018534282"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  app_service_plan_id = azurerm_app_service_plan.test.id

  site_config {
    always_on = true
  }

  auth_settings {
    enabled = true

    twitter {
      consumer_key    = "twitterconsumerkey"
      consumer_secret = "twitterconsumersecret"
    }
  }
}
