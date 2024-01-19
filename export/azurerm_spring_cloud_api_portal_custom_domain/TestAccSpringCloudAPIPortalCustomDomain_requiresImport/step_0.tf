

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-spring-240119025843878537"
  location = "West Europe"
}

resource "azurerm_spring_cloud_service" "test" {
  name                = "acctest-sc-240119025843878537"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "E0"
}

resource "azurerm_spring_cloud_api_portal" "test" {
  name                    = "default"
  spring_cloud_service_id = azurerm_spring_cloud_service.test.id
}


resource "azurerm_spring_cloud_api_portal_custom_domain" "test" {
  name                       = "${azurerm_spring_cloud_service.test.name}.azuremicroservices.io"
  spring_cloud_api_portal_id = azurerm_spring_cloud_api_portal.test.id
}
