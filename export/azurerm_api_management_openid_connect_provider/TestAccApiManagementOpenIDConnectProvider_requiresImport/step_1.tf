


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221221203917769013"
  location = "West Europe"
}

resource "azurerm_api_management" "test" {
  name                = "acctestAM-221221203917769013"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  publisher_name      = "pub1"
  publisher_email     = "pub1@email.com"
  sku_name            = "Consumption_0"
}


resource "azurerm_api_management_openid_connect_provider" "test" {
  name                = "acctest-221221203917769013"
  api_management_name = azurerm_api_management.test.name
  resource_group_name = azurerm_resource_group.test.name
  client_id           = "00001111-2222-3333-221221203917769013"
  client_secret       = "221221203917769013-cwdavsxbacsaxZX-221221203917769013"
  display_name        = "Initial Name"
  metadata_endpoint   = "https://azacceptance.hashicorptest.com/example/foo"
}


resource "azurerm_api_management_openid_connect_provider" "import" {
  name                = azurerm_api_management_openid_connect_provider.test.name
  api_management_name = azurerm_api_management_openid_connect_provider.test.api_management_name
  resource_group_name = azurerm_api_management_openid_connect_provider.test.resource_group_name
  client_id           = azurerm_api_management_openid_connect_provider.test.client_id
  client_secret       = azurerm_api_management_openid_connect_provider.test.client_secret
  display_name        = azurerm_api_management_openid_connect_provider.test.display_name
  metadata_endpoint   = azurerm_api_management_openid_connect_provider.test.metadata_endpoint
}
