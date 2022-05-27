
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-dns-220527034132467067"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone220527034132467067.com"
  resource_group_name = azurerm_resource_group.test.name

  soa_record {
    email     = "testemail.com"
    host_name = "testhost.contoso.com"
  }
}
