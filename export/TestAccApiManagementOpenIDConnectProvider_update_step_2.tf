

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220916011039838834"
  location = "West Europe"
}

resource "azurerm_api_management" "test" {
  name                = "acctestAM-220916011039838834"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  publisher_name      = "pub1"
  publisher_email     = "pub1@email.com"
  sku_name            = "Consumption_0"
}


resource "azurerm_api_management_openid_connect_provider" "test" {
  name                = "acctest-220916011039838834"
  api_management_name = azurerm_api_management.test.name
  resource_group_name = azurerm_resource_group.test.name
  client_id           = "00001111-3333-2222-220916011039838834"
  client_secret       = "220916011039838834-423egvwdcsjx-220916011039838834"
  display_name        = "Updated Name"
  description         = "Example description"
  metadata_endpoint   = "https://azacceptance.hashicorptest.com/example/updated"
}
