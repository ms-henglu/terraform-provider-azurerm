

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119024407423500"
  location = "West Europe"
}

resource "azurerm_api_management" "test" {
  name                = "acctestAM-240119024407423500"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  publisher_name      = "pub1"
  publisher_email     = "pub1@email.com"

  sku_name = "Consumption_0"
}


resource "azurerm_api_management_openid_connect_provider" "test" {
  name                = "acctest-240119024407423500"
  api_management_name = azurerm_api_management.test.name
  resource_group_name = azurerm_resource_group.test.name
  client_id           = "00001111-2222-3333-240119024407423500"
  client_secret       = "240119024407423500-cwdavsxbacsaxZX-240119024407423500"
  display_name        = "Initial Name"
  metadata_endpoint   = "https://azacceptance.hashicorptest.com/example/foo"
}

resource "azurerm_api_management_api" "test" {
  name                = "acctestapi-240119024407423500"
  resource_group_name = azurerm_resource_group.test.name
  api_management_name = azurerm_api_management.test.name
  display_name        = "api1"
  path                = "api1"
  protocols           = ["https"]
  revision            = "1"
  openid_authentication {
    openid_provider_name = azurerm_api_management_openid_connect_provider.test.name
    bearer_token_sending_methods = [
      "authorizationHeader",
      "query",
    ]
  }
}
