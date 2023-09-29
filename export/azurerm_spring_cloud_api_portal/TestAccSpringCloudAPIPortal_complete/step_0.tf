

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-spring-230929065733987024"
  location = "West Europe"
}

resource "azurerm_spring_cloud_service" "test" {
  name                = "acctest-sc-230929065733987024"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "E0"
}

resource "azurerm_spring_cloud_gateway" "test" {
  name                    = "default"
  spring_cloud_service_id = azurerm_spring_cloud_service.test.id
}

data "azurerm_client_config" "current" {
}

resource "azurerm_spring_cloud_api_portal" "test" {
  name                          = "default"
  spring_cloud_service_id       = azurerm_spring_cloud_service.test.id
  gateway_ids                   = [azurerm_spring_cloud_gateway.test.id]
  https_only_enabled            = false
  public_network_access_enabled = false
  instance_count                = 1

  sso {
    client_id     = "ARM_CLIENT_ID"
    client_secret = "ARM_CLIENT_SECRET"
    issuer_uri    = "https://login.microsoftonline.com/${data.azurerm_client_config.current.tenant_id}/v2.0"
    scope         = ["read"]
  }
}
