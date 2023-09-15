

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-api-230915022812164131"
  location = "West Europe"
}

resource "azurerm_api_management" "test" {
  name                = "acctestAM-230915022812164131"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  publisher_name      = "pub1"
  publisher_email     = "pub1@email.com"
  sku_name            = "Developer_1"
}

resource "azurerm_api_management_identity_provider_aad" "test" {
  resource_group_name = azurerm_resource_group.test.name
  api_management_name = azurerm_api_management.test.name
  client_id           = "00000000-0000-0000-0000-000000000000"
  client_secret       = "00000000000000000000000000000000"
  signin_tenant       = "00000000-0000-0000-0000-000000000000"
  allowed_tenants     = ["ARM_TENANT_ID"]
}


resource "azurerm_api_management_identity_provider_aad" "import" {
  resource_group_name = azurerm_api_management_identity_provider_aad.test.resource_group_name
  api_management_name = azurerm_api_management_identity_provider_aad.test.api_management_name
  client_id           = azurerm_api_management_identity_provider_aad.test.client_id
  client_secret       = azurerm_api_management_identity_provider_aad.test.client_secret
  allowed_tenants     = azurerm_api_management_identity_provider_aad.test.allowed_tenants
}
