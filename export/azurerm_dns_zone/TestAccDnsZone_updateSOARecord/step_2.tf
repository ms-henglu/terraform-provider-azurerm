
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-dns-230922061103896576"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone230922061103896576.com"
  resource_group_name = azurerm_resource_group.test.name

  soa_record {
    email = "testemail.com"
  }
}
