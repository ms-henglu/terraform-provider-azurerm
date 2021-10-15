
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211015014218653699"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone211015014218653699.com"
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_dns_a_record" "test" {
  name                = "myarecord211015014218653699"
  resource_group_name = azurerm_resource_group.test.name
  zone_name           = azurerm_dns_zone.test.name
  ttl                 = 300
  records             = ["1.2.3.4", "1.2.4.5"]
}
