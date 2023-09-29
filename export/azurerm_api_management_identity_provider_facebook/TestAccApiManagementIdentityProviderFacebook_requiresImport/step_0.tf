
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-api-230929064257527555"
  location = "West Europe"
}

resource "azurerm_api_management" "test" {
  name                = "acctestAM-230929064257527555"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  publisher_name      = "pub1"
  publisher_email     = "pub1@email.com"
  sku_name            = "Developer_1"
}

resource "azurerm_api_management_identity_provider_facebook" "test" {
  resource_group_name = azurerm_resource_group.test.name
  api_management_name = azurerm_api_management.test.name
  app_id              = "00000000000000000000000000000000"
  app_secret          = "00000000000000000000000000000000"
}
