
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221111013517860451"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone221111013517860451.com"
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_dns_caa_record" "test" {
  name                = "myarecord221111013517860451"
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
    environment = "staging"
  }
}
