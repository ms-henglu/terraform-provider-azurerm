
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-prvdns-231218072403941633"
  location = "West Europe"
}

resource "azurerm_private_dns_zone" "test" {
  name                = "testzone231218072403941633.com"
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_private_dns_txt_record" "test" {
  name                = "test231218072403941633"
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
    environment = "staging"
  }
}
