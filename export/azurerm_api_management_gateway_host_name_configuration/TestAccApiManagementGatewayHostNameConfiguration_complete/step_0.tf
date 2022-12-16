
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221216013034394867"
  location = "West Europe"
}

resource "azurerm_api_management" "test" {
  name                = "acctestAM-221216013034394867"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  publisher_name      = "pub1"
  publisher_email     = "pub1@email.com"

  sku_name = "Developer_1"
}

resource "azurerm_api_management_gateway" "test" {
  name              = "acctestAMGateway-221216013034394867"
  api_management_id = azurerm_api_management.test.id

  location_data {
    name = "test"
  }
}

resource "azurerm_api_management_certificate" "test" {
  name                = "example-cert"
  api_management_name = azurerm_api_management.test.name
  resource_group_name = azurerm_resource_group.test.name
  data                = filebase64("testdata/keyvaultcert.pfx")
  password            = ""
}

resource "azurerm_api_management_gateway_host_name_configuration" "test" {
  name              = "acctestAMGatewayHostNameConfiguration-221216013034394867"
  api_management_id = azurerm_api_management.test.id
  gateway_name      = azurerm_api_management_gateway.test.name

  certificate_id                     = azurerm_api_management_certificate.test.id
  host_name                          = "host-name-221216013034394867"
  request_client_certificate_enabled = true
  http2_enabled                      = true
  tls10_enabled                      = true
  tls11_enabled                      = false
}
