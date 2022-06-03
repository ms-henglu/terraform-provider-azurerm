
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220603005209916683"
  location = "West Europe"
}

resource "azurerm_private_dns_zone" "test" {
  name                = "testzone220603005209916683.com"
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_private_dns_srv_record" "test" {
  name                = "test220603005209916683"
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
  record {
    priority = 20
    weight   = 100
    port     = 8080
    target   = "target3.contoso.com"
  }
}
