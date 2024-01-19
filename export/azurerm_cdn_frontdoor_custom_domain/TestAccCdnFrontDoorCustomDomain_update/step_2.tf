

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-cdn-afdx-240119024619110107"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone240119024619110107.com"
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_cdn_frontdoor_profile" "test" {
  name                = "acctestcdnfdprofile-240119024619110107"
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "Standard_AzureFrontDoor"
}


resource "azurerm_cdn_frontdoor_custom_domain" "test" {
  name                     = "acctestcustomdomain-240119024619110107"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.test.id
  dns_zone_id              = azurerm_dns_zone.test.id
  host_name                = join(".", ["sub-z3lr1w2n", azurerm_dns_zone.test.name])

  tls {
    certificate_type    = "ManagedCertificate"
    minimum_tls_version = "TLS10"
  }
}
