
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220527034132468360"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone220527034132468360.com"
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_dns_a_record" "test" {
  name                = "myarecord220527034132468360"
  resource_group_name = azurerm_resource_group.test.name
  zone_name           = azurerm_dns_zone.test.name
  ttl                 = 300
  records             = ["1.2.3.4", "1.2.4.5"]
}
