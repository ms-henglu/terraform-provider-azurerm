
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240105060149940895"
  location = "West Europe"
}

resource "azurerm_api_management" "test" {
  name                = "acctestAM-240105060149940895"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  publisher_name      = "pub1"
  publisher_email     = "pub1@email.com"

  sku_name = "Developer_1"
}

resource "azurerm_api_management_gateway" "test" {
  name              = "acctestAMGateway-240105060149940895"
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

resource "azurerm_api_management_gateway_certificate_authority" "test" {
  api_management_id = azurerm_api_management.test.id
  certificate_name  = azurerm_api_management_certificate.test.name
  gateway_name      = azurerm_api_management_gateway.test.name
  is_trusted        = true
}

