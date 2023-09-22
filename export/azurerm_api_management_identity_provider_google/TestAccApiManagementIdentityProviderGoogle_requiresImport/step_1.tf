

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-api-230922053516771484"
  location = "West Europe"
}

resource "azurerm_api_management" "test" {
  name                = "acctestAM-230922053516771484"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  publisher_name      = "pub1"
  publisher_email     = "pub1@email.com"
  sku_name            = "Developer_1"
}

resource "azurerm_api_management_identity_provider_google" "test" {
  resource_group_name = azurerm_resource_group.test.name
  api_management_name = azurerm_api_management.test.name
  client_id           = "00000000.apps.googleusercontent.com"
  client_secret       = "00000000000000000000000000000000"
}


resource "azurerm_api_management_identity_provider_google" "import" {
  resource_group_name = azurerm_api_management_identity_provider_google.test.resource_group_name
  api_management_name = azurerm_api_management_identity_provider_google.test.api_management_name
  client_id           = azurerm_api_management_identity_provider_google.test.client_id
  client_secret       = azurerm_api_management_identity_provider_google.test.client_secret
}
