
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230512010644303402"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone230512010644303402.com"
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_dns_caa_record" "test" {
  name                = "myarecord230512010644303402"
  resource_group_name = azurerm_resource_group.test.name
  zone_name           = azurerm_dns_zone.test.name
  ttl                 = 300

  record {
    flags = 0
    tag   = "issue"
    value = "example.net"
  }

  record {
    flags = 1
    tag   = "issuewild"
    value = ";"
  }

  tags = {
    environment = "Production"
    cost_center = "MSFT"
  }
}
