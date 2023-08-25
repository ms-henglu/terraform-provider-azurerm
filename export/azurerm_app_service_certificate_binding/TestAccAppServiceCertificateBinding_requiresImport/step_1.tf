

provider "azurerm" {
  features {}
}

resource "azurerm_app_service_certificate_binding" "test" {
  hostname_binding_id = azurerm_app_service_custom_hostname_binding.test.id
  certificate_id      = azurerm_app_service_managed_certificate.test.id
  ssl_state           = "IpBasedEnabled"
}



resource "azurerm_resource_group" "test" {
  name     = "acctestRG-asmc-230825025504249438"
  location = "West Europe"
}

resource "azurerm_app_service_plan" "test" {
  name                = "acctestASP-230825025504249438"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  kind                = "Linux"

  sku {
    tier = "Basic"
    size = "B1"
  }

  reserved = true
}

resource "azurerm_app_service" "test" {
  name                = "acctestxdmxi"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  app_service_plan_id = azurerm_app_service_plan.test.id
}

data "azurerm_dns_zone" "test" {
  name                = "ARM_TEST_DNS_ZONE"
  resource_group_name = "ARM_TEST_DATA_RESOURCE_GROUP"
}

resource "azurerm_dns_cname_record" "test" {
  name                = "xdmxi"
  zone_name           = data.azurerm_dns_zone.test.name
  resource_group_name = data.azurerm_dns_zone.test.resource_group_name
  ttl                 = 300
  record              = azurerm_app_service.test.default_site_hostname
}

resource "azurerm_dns_txt_record" "test" {
  name                = join(".", ["asuid", "xdmxi"])
  zone_name           = data.azurerm_dns_zone.test.name
  resource_group_name = data.azurerm_dns_zone.test.resource_group_name
  ttl                 = 300

  record {
    value = azurerm_app_service.test.custom_domain_verification_id
  }
}

resource "azurerm_app_service_custom_hostname_binding" "test" {
  hostname            = join(".", [azurerm_dns_cname_record.test.name, azurerm_dns_cname_record.test.zone_name])
  app_service_name    = azurerm_app_service.test.name
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_app_service_managed_certificate" "test" {
  custom_hostname_binding_id = azurerm_app_service_custom_hostname_binding.test.id
}



resource "azurerm_app_service_certificate_binding" "import" {
  hostname_binding_id = azurerm_app_service_certificate_binding.test.hostname_binding_id
  certificate_id      = azurerm_app_service_certificate_binding.test.certificate_id
  ssl_state           = azurerm_app_service_certificate_binding.test.ssl_state
}
