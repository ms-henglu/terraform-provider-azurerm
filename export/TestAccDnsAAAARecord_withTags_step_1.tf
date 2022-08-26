
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220826002707298142"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone220826002707298142.com"
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_dns_aaaa_record" "test" {
  name                = "myarecord220826002707298142"
  resource_group_name = azurerm_resource_group.test.name
  zone_name           = azurerm_dns_zone.test.name
  ttl                 = 300
  records             = ["2607:f8b0:4009:1803::1005", "2607:f8b0:4009:1803::1006"]

  tags = {
    environment = "staging"
  }
}
