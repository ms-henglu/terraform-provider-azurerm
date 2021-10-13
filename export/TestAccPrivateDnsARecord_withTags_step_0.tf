
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211013072253146940"
  location = "West Europe"
}

resource "azurerm_private_dns_zone" "test" {
  name                = "acctestzone211013072253146940.com"
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_private_dns_a_record" "test" {
  name                = "myarecord211013072253146940"
  resource_group_name = azurerm_resource_group.test.name
  zone_name           = azurerm_private_dns_zone.test.name
  ttl                 = 300
  records             = ["1.2.3.4", "1.2.4.5"]

  tags = {
    environment = "Production"
    cost_center = "MSFT"
  }
}
