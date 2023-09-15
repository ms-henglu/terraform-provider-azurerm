
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-api-230915022812163229"
  location = "West Europe"
}

resource "azurerm_api_management" "test" {
  name                = "acctestAM-230915022812163229"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  publisher_name      = "pub1"
  publisher_email     = "pub1@email.com"
  sku_name            = "Developer_1"
}

resource "azurerm_api_management_identity_provider_facebook" "test" {
  resource_group_name = azurerm_resource_group.test.name
  api_management_name = azurerm_api_management.test.name
  app_id              = "11111111111111111111111111111111"
  app_secret          = "11111111111111111111111111111111"
}
