

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221124181202627426"
  location = "West Europe"
}

resource "azurerm_api_management" "test" {
  name                = "acctestAM-221124181202627426"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  publisher_name      = "pub1"
  publisher_email     = "pub1@email.com"
  sku_name            = "Consumption_0"
}


resource "azurerm_api_management_authorization_server" "test" {
  name                         = "acctestauthsrv-221124181202627426"
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
