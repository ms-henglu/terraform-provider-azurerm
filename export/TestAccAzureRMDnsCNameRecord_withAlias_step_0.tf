
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211001020744652085"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone211001020744652085.com"
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_dns_cname_record" "target" {
  name                = "mycnametarget211001020744652085"
  resource_group_name = azurerm_resource_group.test.name
  zone_name           = azurerm_dns_zone.test.name
  ttl                 = 300
  record              = "contoso.com"
}

resource "azurerm_dns_cname_record" "test" {
  name                = "mycnamerecord211001020744652085"
  resource_group_name = azurerm_resource_group.test.name
  zone_name           = azurerm_dns_zone.test.name
  ttl                 = 300
  target_resource_id  = azurerm_dns_cname_record.target.id
}
