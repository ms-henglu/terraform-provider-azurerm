
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221111014426371305"
  location = "West Europe"
}

resource "azurerm_app_service_certificate_order" "test" {
  name                = "acctestASCO-221111014426371305"
  location            = "global"
  resource_group_name = azurerm_resource_group.test.name
  distinguished_name  = "CN=example.com"
  product_type        = "Standard"
}
