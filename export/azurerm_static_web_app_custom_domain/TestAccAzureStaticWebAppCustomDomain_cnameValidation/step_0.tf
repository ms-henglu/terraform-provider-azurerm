
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240311031305950241"
  location = "West Europe"
}

data "azurerm_dns_zone" "test" {
  name                = "ARM_TEST_DNS_ZONE"
  resource_group_name = "ARM_TEST_DATA_RESOURCE_GROUP"
}

resource "azurerm_dns_cname_record" "test" {
  name                = "swa240311031305950241"
  resource_group_name = data.azurerm_dns_zone.test.resource_group_name
  zone_name           = data.azurerm_dns_zone.test.name
  ttl                 = 300
  record              = azurerm_static_web_app.test.default_host_name
}

resource "azurerm_static_web_app" "test" {
  name                = "acctestSS-240311031305950241"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_size            = "Standard"
  sku_tier            = "Standard"
}

resource "azurerm_static_web_app_custom_domain" "test" {
  static_web_app_id = azurerm_static_web_app.test.id
  domain_name       = trimsuffix(azurerm_dns_cname_record.test.fqdn, ".")
  validation_type   = "cname-delegation"
}
