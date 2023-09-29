


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-spring-230929065734003166"
  location = "West Europe"
}

resource "azurerm_spring_cloud_service" "test" {
  name                = "acctest-sc-230929065734003166"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "E0"
}

resource "azurerm_spring_cloud_gateway" "test" {
  name                    = "default"
  spring_cloud_service_id = azurerm_spring_cloud_service.test.id
}

resource "azurerm_spring_cloud_app" "test" {
  name                = "acctest-sca-230929065734003166"
  resource_group_name = azurerm_spring_cloud_service.test.resource_group_name
  service_name        = azurerm_spring_cloud_service.test.name
}


resource "azurerm_spring_cloud_gateway_route_config" "test" {
  name                    = "acctest-agrc-230929065734003166"
  spring_cloud_gateway_id = azurerm_spring_cloud_gateway.test.id
  spring_cloud_app_id     = azurerm_spring_cloud_app.test.id
}


resource "azurerm_spring_cloud_gateway_route_config" "import" {
  name                    = azurerm_spring_cloud_gateway_route_config.test.name
  spring_cloud_gateway_id = azurerm_spring_cloud_gateway_route_config.test.spring_cloud_gateway_id
  spring_cloud_app_id     = azurerm_spring_cloud_gateway_route_config.test.spring_cloud_app_id
}
