
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230512003936980246"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone230512003936980246.com"
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_dns_srv_record" "test" {
  name                = "myarecord230512003936980246"
  resource_group_name = azurerm_resource_group.test.name
  zone_name           = azurerm_dns_zone.test.name
  ttl                 = 300

  record {
    priority = 1
    weight   = 5
    port     = 8080
    target   = "target1.contoso.com"
  }

  record {
    priority = 2
    weight   = 25
    port     = 8080
    target   = "target2.contoso.com"
  }

  record {
    priority = 3
    weight   = 100
    port     = 8080
    target   = "target3.contoso.com"
  }
}
