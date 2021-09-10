
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-dns-210910021358460243"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone210910021358460243.com"
  resource_group_name = azurerm_resource_group.test.name

  soa_record {
    email     = "testemail.com"
    host_name = "testhost.contoso.com"
  }
}
