
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220826003148784267"
  location = "West Europe"
}

resource "azurerm_private_dns_zone" "test" {
  name                = "acctestzone220826003148784267.com"
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_private_dns_a_record" "test" {
  name                = "myarecord220826003148784267"
  resource_group_name = azurerm_resource_group.test.name
  zone_name           = azurerm_private_dns_zone.test.name
  ttl                 = 300
  records             = ["1.2.3.4", "1.2.4.5"]
}
