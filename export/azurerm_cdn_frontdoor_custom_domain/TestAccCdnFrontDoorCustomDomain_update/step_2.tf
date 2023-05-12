

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-cdn-afdx-230512003539144226"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone230512003539144226.com"
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_cdn_frontdoor_profile" "test" {
  name                = "acctestcdnfdprofile-230512003539144226"
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "Standard_AzureFrontDoor"
}


resource "azurerm_cdn_frontdoor_custom_domain" "test" {
  name                     = "acctestcustomdomain-230512003539144226"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.test.id
  dns_zone_id              = azurerm_dns_zone.test.id
  host_name                = join(".", ["sub-fpvmpuxs", azurerm_dns_zone.test.name])

  tls {
    certificate_type    = "ManagedCertificate"
    minimum_tls_version = "TLS10"
  }
}
