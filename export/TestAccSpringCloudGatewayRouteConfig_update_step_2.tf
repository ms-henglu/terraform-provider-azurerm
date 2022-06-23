

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-spring-220623234405180495"
  location = "West Europe"
}

resource "azurerm_spring_cloud_service" "test" {
  name                = "acctest-sc-220623234405180495"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "E0"
}

resource "azurerm_spring_cloud_gateway" "test" {
  name                    = "default"
  spring_cloud_service_id = azurerm_spring_cloud_service.test.id
}

resource "azurerm_spring_cloud_app" "test" {
  name                = "acctest-sca-220623234405180495"
  resource_group_name = azurerm_spring_cloud_service.test.resource_group_name
  service_name        = azurerm_spring_cloud_service.test.name
}


resource "azurerm_spring_cloud_gateway_route_config" "test" {
  name                    = "acctest-agrc-220623234405180495"
  spring_cloud_gateway_id = azurerm_spring_cloud_gateway.test.id
  spring_cloud_app_id     = azurerm_spring_cloud_app.test.id
  route {
    description            = "test description"
    filters                = ["StripPrefix=2", "RateLimit=1,1s"]
    order                  = 1
    predicates             = ["Path=/api5/customer/**"]
    sso_validation_enabled = true
    title                  = "myApp route config"
    token_relay            = true
    uri                    = "https://www.test.com"
    classification_tags    = ["tag1", "tag2"]
  }
}
