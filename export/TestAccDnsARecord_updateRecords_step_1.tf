
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220826002707295595"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone220826002707295595.com"
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_dns_a_record" "test" {
  name                = "myarecord220826002707295595"
  resource_group_name = azurerm_resource_group.test.name
  zone_name           = azurerm_dns_zone.test.name
  ttl                 = 300
  records             = ["1.2.3.4", "1.2.4.5", "1.2.3.7"]
}
