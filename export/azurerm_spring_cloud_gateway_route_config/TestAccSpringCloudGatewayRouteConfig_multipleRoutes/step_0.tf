

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-spring-230929065734006989"
  location = "West Europe"
}

resource "azurerm_spring_cloud_service" "test" {
  name                = "acctest-sc-230929065734006989"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "E0"
}

resource "azurerm_spring_cloud_gateway" "test" {
  name                    = "default"
  spring_cloud_service_id = azurerm_spring_cloud_service.test.id
}

resource "azurerm_spring_cloud_app" "test" {
  name                = "acctest-sca-230929065734006989"
  resource_group_name = azurerm_spring_cloud_service.test.resource_group_name
  service_name        = azurerm_spring_cloud_service.test.name
}


resource "azurerm_spring_cloud_gateway_route_config" "test" {
  name                    = "acctest-agrc-230929065734006989"
  spring_cloud_gateway_id = azurerm_spring_cloud_gateway.test.id
  spring_cloud_app_id     = azurerm_spring_cloud_app.test.id
  route {
    description            = "first route"
    filters                = ["StripPrefix=2", "RateLimit=1,1s"]
    order                  = 1
    predicates             = ["Path=/api5/customer/**"]
    sso_validation_enabled = true
    title                  = "first route config"
    token_relay            = true
    uri                    = "https://www.test1.com"
    classification_tags    = ["route1_tag1", "route1_tag2"]
  }
  route {
    description            = "second route"
    filters                = ["StripPrefix=2", "RateLimit=1,1s"]
    order                  = 2
    predicates             = ["Path=/api5/customer/**"]
    sso_validation_enabled = true
    title                  = "second route config"
    token_relay            = true
    uri                    = "https://www.test2.com"
    classification_tags    = ["route2_tag1", "route2_tag2"]
  }
  open_api {
    uri = "https://raw.githubusercontent.com/OAI/OpenAPI-Specification/main/examples/v3.0/petstore.json"
  }
}
