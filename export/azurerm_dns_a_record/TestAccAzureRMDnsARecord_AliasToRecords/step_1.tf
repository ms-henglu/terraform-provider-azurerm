
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119025001774969"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone240119025001774969.com"
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_dns_a_record" "test" {
  name                = "myarecord240119025001774969"
  resource_group_name = azurerm_resource_group.test.name
  zone_name           = azurerm_dns_zone.test.name
  ttl                 = 300
  records             = ["1.2.3.4", "1.2.4.5"]
}
