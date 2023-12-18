
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-dns-231218071732214404"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone231218071732214404.com"
  resource_group_name = azurerm_resource_group.test.name

  soa_record {
    email         = "testemail.com"
    expire_time   = 2419200
    minimum_ttl   = 200
    refresh_time  = 2600
    retry_time    = 200
    serial_number = 1
    ttl           = 100

    tags = {
      ENv = "Test"
    }
  }
}
