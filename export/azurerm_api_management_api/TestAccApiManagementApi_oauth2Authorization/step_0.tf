

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119024407427186"
  location = "West Europe"
}

resource "azurerm_api_management" "test" {
  name                = "acctestAM-240119024407427186"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  publisher_name      = "pub1"
  publisher_email     = "pub1@email.com"

  sku_name = "Consumption_0"
}


resource "azurerm_api_management_authorization_server" "test" {
  name                         = "acctestauthsrv-240119024407427186"
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

resource "azurerm_api_management_api" "test" {
  name                = "acctestapi-240119024407427186"
  resource_group_name = azurerm_resource_group.test.name
  api_management_name = azurerm_api_management.test.name
  display_name        = "api1"
  path                = "api1"
  protocols           = ["https"]
  revision            = "1"
  oauth2_authorization {
    authorization_server_name = azurerm_api_management_authorization_server.test.name
    scope                     = "acctest"
  }
}
