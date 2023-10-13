
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-dns-231013043424861971"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone231013043424861971.com"
  resource_group_name = azurerm_resource_group.test.name

  soa_record {
    email = "testemail.com"
  }
}
