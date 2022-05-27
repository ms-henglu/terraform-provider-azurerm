
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220527034549483608"
  location = "West Europe"
}

resource "azurerm_private_dns_zone" "test" {
  name                = "acctestzone220527034549483608.com"
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_private_dns_a_record" "test" {
  name                = "myarecord220527034549483608"
  resource_group_name = azurerm_resource_group.test.name
  zone_name           = azurerm_private_dns_zone.test.name
  ttl                 = 300
  records             = ["1.2.3.4", "1.2.4.5"]
}
