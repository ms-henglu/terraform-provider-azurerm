


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-spring-230922061952545936"
  location = "West Europe"
}

resource "azurerm_spring_cloud_service" "test" {
  name                = "acctest-sc-230922061952545936"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_spring_cloud_app" "test" {
  name                = "acctest-sca-230922061952545936"
  resource_group_name = azurerm_spring_cloud_service.test.resource_group_name
  service_name        = azurerm_spring_cloud_service.test.name
}

data "azurerm_dns_zone" "test" {
  name                = "ARM_TEST_DNS_ZONE"
  resource_group_name = "ARM_TEST_DATA_RESOURCE_GROUP"
}

resource "azurerm_dns_cname_record" "test" {
  name                = "7rd12"
  zone_name           = data.azurerm_dns_zone.test.name
  resource_group_name = data.azurerm_dns_zone.test.resource_group_name
  ttl                 = 300
  record              = azurerm_spring_cloud_app.test.fqdn
}


resource "azurerm_spring_cloud_custom_domain" "test" {
  name                = join(".", [azurerm_dns_cname_record.test.name, azurerm_dns_cname_record.test.zone_name])
  spring_cloud_app_id = azurerm_spring_cloud_app.test.id
}


resource "azurerm_spring_cloud_custom_domain" "import" {
  name                = azurerm_spring_cloud_custom_domain.test.name
  spring_cloud_app_id = azurerm_spring_cloud_custom_domain.test.spring_cloud_app_id
}
