


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-cdn-afdx-221104005155219034"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone221104005155219034.com"
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_cdn_frontdoor_profile" "test" {
  name                = "acctestcdnfdprofile-221104005155219034"
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "Standard_AzureFrontDoor"
}


resource "azurerm_cdn_frontdoor_custom_domain" "test" {
  name                     = "acctestcustomdomain-221104005155219034"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.test.id
  dns_zone_id              = azurerm_dns_zone.test.id
  host_name                = join(".", ["8md36bm0", azurerm_dns_zone.test.name])

  tls {
    certificate_type    = "ManagedCertificate"
    minimum_tls_version = "TLS12"
  }
}


resource "azurerm_cdn_frontdoor_custom_domain" "import" {
  name                     = azurerm_cdn_frontdoor_custom_domain.test.name
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_custom_domain.test.cdn_frontdoor_profile_id
  dns_zone_id              = azurerm_cdn_frontdoor_custom_domain.test.dns_zone_id
  host_name                = azurerm_cdn_frontdoor_custom_domain.test.host_name

  tls {
    certificate_type    = "ManagedCertificate"
    minimum_tls_version = "TLS12"
  }
}
