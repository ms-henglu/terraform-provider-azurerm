
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211015014218654165"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone211015014218654165.com"
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_dns_cname_record" "target" {
  name                = "mycnametarget211015014218654165"
  resource_group_name = azurerm_resource_group.test.name
  zone_name           = azurerm_dns_zone.test.name
  ttl                 = 300
  record              = "contoso.com"
}

resource "azurerm_dns_cname_record" "test" {
  name                = "mycnamerecord211015014218654165"
  resource_group_name = azurerm_resource_group.test.name
  zone_name           = azurerm_dns_zone.test.name
  ttl                 = 300
  target_resource_id  = azurerm_dns_cname_record.target.id
}
