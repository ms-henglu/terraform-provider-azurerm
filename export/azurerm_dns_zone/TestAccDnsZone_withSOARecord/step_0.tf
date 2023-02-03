
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-dns-230203063327447352"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone230203063327447352.com"
  resource_group_name = azurerm_resource_group.test.name

  soa_record {
    email     = "testemail.com"
    host_name = "testhost.contoso.com"
  }
}
