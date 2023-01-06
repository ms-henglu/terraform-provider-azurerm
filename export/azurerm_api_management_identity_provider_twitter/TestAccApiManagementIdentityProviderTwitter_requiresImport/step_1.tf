

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-api-230106034052090036"
  location = "West Europe"
}

resource "azurerm_api_management" "test" {
  name                = "acctestAM-230106034052090036"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  publisher_name      = "pub1"
  publisher_email     = "pub1@email.com"
  sku_name            = "Developer_1"
}

resource "azurerm_api_management_identity_provider_twitter" "test" {
  resource_group_name = azurerm_resource_group.test.name
  api_management_name = azurerm_api_management.test.name
  api_key             = "00000000000000000000000000000000"
  api_secret_key      = "00000000000000000000000000000000"
}


resource "azurerm_api_management_identity_provider_twitter" "import" {
  resource_group_name = azurerm_api_management_identity_provider_twitter.test.resource_group_name
  api_management_name = azurerm_api_management_identity_provider_twitter.test.api_management_name
  api_key             = azurerm_api_management_identity_provider_twitter.test.api_key
  api_secret_key      = azurerm_api_management_identity_provider_twitter.test.api_secret_key
}
