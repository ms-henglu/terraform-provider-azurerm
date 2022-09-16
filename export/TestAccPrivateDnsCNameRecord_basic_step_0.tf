
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220916011904836736"
  location = "West Europe"
}

resource "azurerm_private_dns_zone" "test" {
  name                = "acctestzone220916011904836736.com"
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_private_dns_cname_record" "test" {
  name                = "acctestcname220916011904836736"
  resource_group_name = azurerm_resource_group.test.name
  zone_name           = azurerm_private_dns_zone.test.name
  ttl                 = 300
  record              = "contoso.com"
}
