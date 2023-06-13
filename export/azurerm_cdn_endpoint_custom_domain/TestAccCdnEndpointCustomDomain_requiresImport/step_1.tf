


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acceptanceRG-23061322"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acceptancesa23061322"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
}

resource "azurerm_cdn_profile" "test" {
  name                = "acceptancecdnprof23061322"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard_Microsoft"
}

resource "azurerm_cdn_endpoint" "test" {
  name                = "acceptancecdnend23061322"
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
  name                = "0th"
  zone_name           = data.azurerm_dns_zone.test.name
  resource_group_name = data.azurerm_dns_zone.test.resource_group_name
  ttl                 = 3600
  target_resource_id  = azurerm_cdn_endpoint.test.id
}


resource "azurerm_cdn_endpoint_custom_domain" "test" {
  name            = "acceptance-customdomain"
  cdn_endpoint_id = azurerm_cdn_endpoint.test.id
  host_name       = "${azurerm_dns_cname_record.test.name}.${data.azurerm_dns_zone.test.name}"
}


resource "azurerm_cdn_endpoint_custom_domain" "import" {
  name            = azurerm_cdn_endpoint_custom_domain.test.name
  cdn_endpoint_id = azurerm_cdn_endpoint_custom_domain.test.cdn_endpoint_id
  host_name       = azurerm_cdn_endpoint_custom_domain.test.host_name
}
