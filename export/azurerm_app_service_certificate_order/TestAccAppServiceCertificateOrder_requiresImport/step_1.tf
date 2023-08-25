

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230825025504247344"
  location = "West Europe"
}

resource "azurerm_app_service_certificate_order" "test" {
  name                = "acctestASCO-230825025504247344"
  location            = "global"
  resource_group_name = azurerm_resource_group.test.name
  distinguished_name  = "CN=example.com"
  product_type        = "Standard"
}


resource "azurerm_app_service_certificate_order" "import" {
  name                = azurerm_app_service_certificate_order.test.name
  location            = azurerm_app_service_certificate_order.test.location
  resource_group_name = azurerm_app_service_certificate_order.test.resource_group_name
  distinguished_name  = azurerm_app_service_certificate_order.test.distinguished_name
  product_type        = azurerm_app_service_certificate_order.test.product_type
}
