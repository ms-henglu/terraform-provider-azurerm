
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230825025504273062"
  location = "West Europe"
}

resource "azurerm_app_service_plan" "test" {
  name                = "acctestASP-230825025504273062"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service" "test" {
  name                = "accestAS-230825025504273062"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  app_service_plan_id = azurerm_app_service_plan.test.id
}

data "azurerm_dns_zone" "test" {
  name                = "ARM_TEST_DNS_ZONE"
  resource_group_name = "ARM_TEST_DATA_RESOURCE_GROUP"
}

resource "azurerm_dns_txt_record" "test" {
  name                = join(".", ["asuid", azurerm_app_service_slot.test.name, azurerm_app_service.test.name])
  zone_name           = data.azurerm_dns_zone.test.name
  resource_group_name = data.azurerm_dns_zone.test.resource_group_name
  ttl                 = 300

  record {
    value = azurerm_app_service.test.custom_domain_verification_id
  }
}

resource "azurerm_app_service_slot" "test" {
  name                = "staging"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  app_service_name    = azurerm_app_service.test.name
  app_service_plan_id = azurerm_app_service_plan.test.id
}

resource "azurerm_app_service_slot_custom_hostname_binding" "test" {
  app_service_slot_id = azurerm_app_service_slot.test.id
  hostname            = "staging.accestAS-230825025504273062.ARM_TEST_DNS_ZONE"

  depends_on = [azurerm_dns_txt_record.test]
}
