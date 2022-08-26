
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220826003148780425"
  location = "West Europe"
}

resource "azurerm_private_dns_zone" "test" {
  name                = "acctestzone220826003148780425.com"
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_private_dns_cname_record" "test" {
  name                = "acctestcname220826003148780425"
  resource_group_name = azurerm_resource_group.test.name
  zone_name           = azurerm_private_dns_zone.test.name
  ttl                 = 300
  record              = "contoso.com"
}
