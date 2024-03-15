

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-api-240315122207558728"
  location = "West Europe"
}

resource "azurerm_api_management" "test" {
  name                = "acctestAM-240315122207558728"
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


resource "azurerm_api_management_identity_provider_facebook" "import" {
  resource_group_name = azurerm_api_management_identity_provider_facebook.test.resource_group_name
  api_management_name = azurerm_api_management_identity_provider_facebook.test.api_management_name
  app_id              = azurerm_api_management_identity_provider_facebook.test.app_id
  app_secret          = azurerm_api_management_identity_provider_facebook.test.app_secret
}
