
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119030025585058"
  location = "West Europe"
}

resource "azurerm_app_service_certificate_order" "test" {
  name                = "acctestASCO-240119030025585058"
  location            = "global"
  resource_group_name = azurerm_resource_group.test.name
  distinguished_name  = "CN=example.com"
  product_type        = "Standard"
}
