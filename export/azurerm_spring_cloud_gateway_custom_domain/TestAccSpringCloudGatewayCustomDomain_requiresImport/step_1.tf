


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-spring-230922054932307810"
  location = "West Europe"
}

resource "azurerm_spring_cloud_service" "test" {
  name                = "acctest-sc-230922054932307810"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "E0"
}

resource "azurerm_spring_cloud_gateway" "test" {
  name                    = "default"
  spring_cloud_service_id = azurerm_spring_cloud_service.test.id
}


resource "azurerm_spring_cloud_gateway_custom_domain" "test" {
  name                    = "${azurerm_spring_cloud_service.test.name}.azuremicroservices.io"
  spring_cloud_gateway_id = azurerm_spring_cloud_gateway.test.id
}


resource "azurerm_spring_cloud_gateway_custom_domain" "import" {
  name                    = azurerm_spring_cloud_gateway_custom_domain.test.name
  spring_cloud_gateway_id = azurerm_spring_cloud_gateway_custom_domain.test.spring_cloud_gateway_id
}
