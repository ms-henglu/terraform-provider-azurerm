
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-api-231016033300930771"
  location = "West Europe"
}

resource "azurerm_api_management" "test" {
  name                = "acctestAM-231016033300930771"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  publisher_name      = "pub1"
  publisher_email     = "pub1@email.com"
  sku_name            = "Developer_1"
}

resource "azurerm_api_management_identity_provider_aad" "test" {
  resource_group_name = azurerm_resource_group.test.name
  api_management_name = azurerm_api_management.test.name
  client_id           = "11111111-1111-1111-1111-111111111111"
  client_secret       = "11111111111111111111111111111111"
  allowed_tenants     = ["ARM_TENANT_ID", "ARM_TENANT_ID"]
}
