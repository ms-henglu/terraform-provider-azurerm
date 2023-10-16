

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231016033300932084"
  location = "West Europe"
}

resource "azurerm_api_management" "test" {
  name                = "acctestAM-231016033300932084"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  publisher_name      = "pub1"
  publisher_email     = "pub1@email.com"

  sku_name = "Developer_1"
}

resource "azurerm_api_management_gateway" "test" {
  name              = "acctestAMGateway-231016033300932084"
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
  name              = "acctestAMGatewayHostNameConfiguration-231016033300932084"
  api_management_id = azurerm_api_management.test.id
  gateway_name      = azurerm_api_management_gateway.test.name

  certificate_id = azurerm_api_management_certificate.test.id

  host_name = "host-name-231016033300932084"
}


resource "azurerm_api_management_gateway_host_name_configuration" "import" {
  name              = azurerm_api_management_gateway_host_name_configuration.test.name
  api_management_id = azurerm_api_management.test.id
  gateway_name      = azurerm_api_management_gateway_host_name_configuration.test.gateway_name

  certificate_id = azurerm_api_management_gateway_host_name_configuration.test.certificate_id
  host_name      = azurerm_api_management_gateway_host_name_configuration.test.host_name
}
