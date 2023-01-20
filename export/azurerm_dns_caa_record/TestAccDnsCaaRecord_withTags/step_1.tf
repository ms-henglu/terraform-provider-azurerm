
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230120051949860376"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone230120051949860376.com"
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_dns_caa_record" "test" {
  name                = "myarecord230120051949860376"
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
