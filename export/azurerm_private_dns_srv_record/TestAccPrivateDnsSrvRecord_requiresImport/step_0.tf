
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-prvdns-240119025637534335"
  location = "West Europe"
}

resource "azurerm_private_dns_zone" "test" {
  name                = "testzone240119025637534335.com"
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_private_dns_srv_record" "test" {
  name                = "testaccsrv240119025637534335"
  resource_group_name = azurerm_resource_group.test.name
  zone_name           = azurerm_private_dns_zone.test.name
  ttl                 = 300
  record {
    priority = 1
    weight   = 5
    port     = 8080
    target   = "target1.contoso.com"
  }

  record {
    priority = 10
    weight   = 10
    port     = 8080
    target   = "target2.contoso.com"
  }
}
