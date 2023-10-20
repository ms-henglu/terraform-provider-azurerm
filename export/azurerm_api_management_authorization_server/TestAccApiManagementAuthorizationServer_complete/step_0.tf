

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231020040437881047"
  location = "West Europe"
}

resource "azurerm_api_management" "test" {
  name                = "acctestAM-231020040437881047"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  publisher_name      = "pub1"
  publisher_email     = "pub1@email.com"
  sku_name            = "Consumption_0"
}


resource "azurerm_api_management_authorization_server" "test" {
  name                         = "acctestauthsrv-231020040437881047"
  resource_group_name          = azurerm_resource_group.test.name
  api_management_name          = azurerm_api_management.test.name
  display_name                 = "Test Group"
  authorization_endpoint       = "https://azacceptance.hashicorptest.com/client/authorize"
  client_id                    = "42424242-4242-4242-4242-424242424242"
  client_registration_endpoint = "https://azacceptance.hashicorptest.com/client/register"
  description                  = "This is a test description"

  token_body_parameter {
    name  = "test"
    value = "token-body-parameter"
  }

  client_authentication_method = [
    "Basic",
  ]

  grant_types = [
    "authorizationCode",
  ]

  authorization_methods = [
    "GET",
    "POST",
  ]

  bearer_token_sending_methods = [
    "authorizationHeader",
  ]

  client_secret           = "n1n3-m0re-s3a5on5-m0r1y"
  default_scope           = "read write"
  token_endpoint          = "https://azacceptance.hashicorptest.com/client/token"
  resource_owner_username = "rick"
  resource_owner_password = "C-193P"
  support_state           = true
}
