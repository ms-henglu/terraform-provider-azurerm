
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220916011430886039"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone220916011430886039.com"
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_dns_cname_record" "target2" {
  name                = "mycnametarget2209160114308860392"
  resource_group_name = azurerm_resource_group.test.name
  zone_name           = azurerm_dns_zone.test.name
  ttl                 = 300
  record              = "contoso.co.uk"
}

resource "azurerm_dns_cname_record" "test" {
  name                = "mycnamerecord220916011430886039"
  resource_group_name = azurerm_resource_group.test.name
  zone_name           = azurerm_dns_zone.test.name
  ttl                 = 300
  target_resource_id  = azurerm_dns_cname_record.target2.id
}
