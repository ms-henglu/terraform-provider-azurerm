
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240311031305951122"
  location = "West Europe"
}

resource "azurerm_static_web_app" "test" {
  name                = "acctestSS-240311031305951122"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_size            = "Standard"
  sku_tier            = "Standard"
}

resource "azurerm_static_web_app_custom_domain" "test" {
  static_web_app_id = azurerm_static_web_app.test.id
  domain_name       = "acctestSS-240311031305951122.contoso.com"
  validation_type   = "dns-txt-token"
}
