
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221021034102275069"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone221021034102275069.com"
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_dns_a_record" "test" {
  name                = "myarecord221021034102275069"
  resource_group_name = azurerm_resource_group.test.name
  zone_name           = azurerm_dns_zone.test.name
  ttl                 = 300
  records             = ["1.2.3.4", "1.2.4.5"]

  tags = {
    environment = "staging"
  }
}
