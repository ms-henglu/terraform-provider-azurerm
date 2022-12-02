

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221202035104495695"
  location = "West Europe"
}

resource "azurerm_api_management" "test" {
  name                = "acctestAM-221202035104495695"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  publisher_name      = "pub1"
  publisher_email     = "pub1@email.com"

  sku_name = "Developer_1"
}

resource "azurerm_api_management_gateway" "test" {
  name              = "acctestAMGateway-221202035104495695"
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
}


resource "azurerm_api_management_gateway_certificate_authority" "import" {
  api_management_id = azurerm_api_management_gateway_certificate_authority.test.api_management_id
  certificate_name  = azurerm_api_management_gateway_certificate_authority.test.certificate_name
  gateway_name      = azurerm_api_management_gateway_certificate_authority.test.gateway_name
}
