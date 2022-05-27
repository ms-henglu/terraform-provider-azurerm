
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-privatedns-220527034549485927"
  location = "West Europe"
}

resource "azurerm_private_dns_zone" "test" {
  name                = "acctestzone220527034549485927.com"
  resource_group_name = azurerm_resource_group.test.name

  soa_record {
    email = "testemail.com"
  }
}
