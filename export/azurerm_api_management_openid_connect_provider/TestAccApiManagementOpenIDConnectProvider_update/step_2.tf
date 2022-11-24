

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221124181202641461"
  location = "West Europe"
}

resource "azurerm_api_management" "test" {
  name                = "acctestAM-221124181202641461"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  publisher_name      = "pub1"
  publisher_email     = "pub1@email.com"
  sku_name            = "Consumption_0"
}


resource "azurerm_api_management_openid_connect_provider" "test" {
  name                = "acctest-221124181202641461"
  api_management_name = azurerm_api_management.test.name
  resource_group_name = azurerm_resource_group.test.name
  client_id           = "00001111-3333-2222-221124181202641461"
  client_secret       = "221124181202641461-423egvwdcsjx-221124181202641461"
  display_name        = "Updated Name"
  description         = "Example description"
  metadata_endpoint   = "https://azacceptance.hashicorptest.com/example/updated"
}
