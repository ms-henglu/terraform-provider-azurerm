


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240112033744170907"
  location = "West Europe"
}

resource "azurerm_api_management" "test" {
  name                = "acctestAM-240112033744170907"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  publisher_name      = "pub1"
  publisher_email     = "pub1@email.com"
  sku_name            = "Consumption_0"
}


resource "azurerm_api_management_authorization_server" "test" {
  name                         = "acctestauthsrv-240112033744170907"
  resource_group_name          = azurerm_resource_group.test.name
  api_management_name          = azurerm_api_management.test.name
  display_name                 = "Test Group"
  authorization_endpoint       = "https://azacceptance.hashicorptest.com/client/authorize"
  client_id                    = "42424242-4242-4242-4242-424242424242"
  client_registration_endpoint = "https://azacceptance.hashicorptest.com/client/register"

  grant_types = [
    "implicit",
  ]

  authorization_methods = [
    "GET",
  ]
}


resource "azurerm_api_management_authorization_server" "import" {
  name                         = azurerm_api_management_authorization_server.test.name
  resource_group_name          = azurerm_api_management_authorization_server.test.resource_group_name
  api_management_name          = azurerm_api_management_authorization_server.test.api_management_name
  display_name                 = azurerm_api_management_authorization_server.test.display_name
  authorization_endpoint       = azurerm_api_management_authorization_server.test.authorization_endpoint
  client_id                    = azurerm_api_management_authorization_server.test.client_id
  client_registration_endpoint = azurerm_api_management_authorization_server.test.client_registration_endpoint
  grant_types                  = azurerm_api_management_authorization_server.test.grant_types

  authorization_methods = [
    "GET",
  ]
}
