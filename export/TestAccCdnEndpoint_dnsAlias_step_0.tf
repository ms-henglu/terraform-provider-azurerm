
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210917031424814071"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestcdnep210917031424814071.com"
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_cdn_profile" "test" {
  name                = "acctestcdnep210917031424814071"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard_Verizon"
}

resource "azurerm_cdn_endpoint" "test" {
  name                = "acctestcdnep210917031424814071"
  profile_name        = azurerm_cdn_profile.test.name
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  origin {
    name       = "acceptanceTestCdnOrigin1"
    host_name  = "www.contoso.com"
    https_port = 443
    http_port  = 80
  }
}

resource "azurerm_dns_a_record" "test" {
  name                = "myarecord210917031424814071"
  resource_group_name = azurerm_resource_group.test.name
  zone_name           = azurerm_dns_zone.test.name
  ttl                 = 300
  target_resource_id  = azurerm_cdn_endpoint.test.id
}
