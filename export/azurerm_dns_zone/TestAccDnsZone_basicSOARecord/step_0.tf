
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-dns-240119025001791282"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone240119025001791282.com"
  resource_group_name = azurerm_resource_group.test.name

  soa_record {
    email = "testemail.com"
  }
}
