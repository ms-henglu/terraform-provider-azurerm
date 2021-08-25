
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-prvdns-210825030113973210"
  location = "West Europe"
}

resource "azurerm_private_dns_zone" "test" {
  name                = "testzone210825030113973210.com"
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_private_dns_txt_record" "test" {
  name                = "test210825030113973210"
  resource_group_name = azurerm_resource_group.test.name
  zone_name           = azurerm_private_dns_zone.test.name
  ttl                 = 300

  record {
    value = "Quick brown fox"
  }

  record {
    value = "A long text......A long text......A long text......A long text......A long text......A long text......A long text......A long text......A long text......A long text......A long text......A long text......A long text......A long text......A long text......A long text......A long text......A long text......A long text......A long text......A long text......A long text......A long text......A long text......A long text......A long text......A long text......A long text......A long text......A long text......A long text......A long text......A long text......A long text......A long text......A long text......A long text......A long text......A long text......A long text......A long text......A long text......"
  }

  tags = {
    environment = "Production"
    cost_center = "MSFT"
  }
}
