
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230512010644308197"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone230512010644308197.com"
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_dns_cname_record" "target" {
  name                = "mycnametarget230512010644308197"
  resource_group_name = azurerm_resource_group.test.name
  zone_name           = azurerm_dns_zone.test.name
  ttl                 = 300
  record              = "contoso.com"
}

resource "azurerm_dns_cname_record" "test" {
  name                = "mycnamerecord230512010644308197"
  resource_group_name = azurerm_resource_group.test.name
  zone_name           = azurerm_dns_zone.test.name
  ttl                 = 300
  target_resource_id  = azurerm_dns_cname_record.target.id
}
