
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-dns-240105063757850621"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone240105063757850621.com"
  resource_group_name = azurerm_resource_group.test.name

  soa_record {
    email = "testemail.com"
  }
}
