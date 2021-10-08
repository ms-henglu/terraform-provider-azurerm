
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211008044358275713"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone211008044358275713.com"
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_dns_ptr_record" "test" {
  name                = "testptrrecord211008044358275713"
  resource_group_name = azurerm_resource_group.test.name
  zone_name           = azurerm_dns_zone.test.name
  ttl                 = 300
  records             = ["hashicorp.com", "microsoft.com", "reddit.com"]
}
