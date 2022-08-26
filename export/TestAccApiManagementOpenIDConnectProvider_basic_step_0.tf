

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220826002310295436"
  location = "West Europe"
}

resource "azurerm_api_management" "test" {
  name                = "acctestAM-220826002310295436"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  publisher_name      = "pub1"
  publisher_email     = "pub1@email.com"
  sku_name            = "Consumption_0"
}


resource "azurerm_api_management_openid_connect_provider" "test" {
  name                = "acctest-220826002310295436"
  api_management_name = azurerm_api_management.test.name
  resource_group_name = azurerm_resource_group.test.name
  client_id           = "00001111-2222-3333-220826002310295436"
  client_secret       = "220826002310295436-cwdavsxbacsaxZX-220826002310295436"
  display_name        = "Initial Name"
  metadata_endpoint   = "https://azacceptance.hashicorptest.com/example/foo"
}
