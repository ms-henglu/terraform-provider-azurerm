

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acceptanceRG-23092929"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acceptancesa23092929"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
}

resource "azurerm_cdn_profile" "test" {
  name                = "acceptancecdnprof23092929"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard_Microsoft"
}

resource "azurerm_cdn_endpoint" "test" {
  name                = "acceptancecdnend23092929"
  profile_name        = azurerm_cdn_profile.test.name
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  origin {
    name      = "test"
    host_name = azurerm_storage_account.test.primary_blob_host
  }
}

data "azurerm_dns_zone" "test" {
  name                = "ARM_TEST_DNS_ZONE_NAME"
  resource_group_name = "ARM_TEST_DNS_ZONE_RESOURCE_GROUP_NAME"
}

resource "azurerm_dns_cname_record" "test" {
  name                = "jiv"
  zone_name           = data.azurerm_dns_zone.test.name
  resource_group_name = data.azurerm_dns_zone.test.resource_group_name
  ttl                 = 3600
  target_resource_id  = azurerm_cdn_endpoint.test.id
}

resource "azurerm_cdn_endpoint_custom_domain" "test" {
  name            = "testcustomdomain-23092929"
  cdn_endpoint_id = azurerm_cdn_endpoint.test.id
  host_name       = "${azurerm_dns_cname_record.test.name}.${data.azurerm_dns_zone.test.name}"
  cdn_managed_https {
    certificate_type = "Dedicated"
    protocol_type    = "ServerNameIndication"
  }
}
