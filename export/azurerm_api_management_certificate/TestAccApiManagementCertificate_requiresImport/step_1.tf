

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231013042832251176"
  location = "West Europe"
}

resource "azurerm_api_management" "test" {
  name                = "acctestAM-231013042832251176"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  publisher_name      = "pub1"
  publisher_email     = "pub1@email.com"
  sku_name            = "Consumption_0"
}

resource "azurerm_api_management_certificate" "test" {
  name                = "example-cert"
  api_management_name = azurerm_api_management.test.name
  resource_group_name = azurerm_resource_group.test.name
  data                = filebase64("testdata/keyvaultcert.pfx")
  password            = ""
}


resource "azurerm_api_management_certificate" "import" {
  name                = azurerm_api_management_certificate.test.name
  api_management_name = azurerm_api_management_certificate.test.api_management_name
  resource_group_name = azurerm_api_management_certificate.test.resource_group_name
  data                = azurerm_api_management_certificate.test.data
  password            = azurerm_api_management_certificate.test.password
}
