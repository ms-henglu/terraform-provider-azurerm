
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230227180128526772"
  location = "West Europe"
}

resource "azurerm_app_service_certificate_order" "test" {
  name                = "acctestASCO-230227180128526772"
  location            = "global"
  resource_group_name = azurerm_resource_group.test.name
  distinguished_name  = "CN=example.com"
  product_type        = "Standard"
  auto_renew          = false
  validity_in_years   = 1
  key_size            = 4096
}
