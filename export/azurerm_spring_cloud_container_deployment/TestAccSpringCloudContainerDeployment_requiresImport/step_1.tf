


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-spring-230526085926116261"
  location = "West Europe"
}

resource "azurerm_spring_cloud_service" "test" {
  name                = "acctest-sc-230526085926116261"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "E0"
}

resource "azurerm_spring_cloud_app" "test" {
  name                = "acctest-sca-230526085926116261"
  resource_group_name = azurerm_spring_cloud_service.test.resource_group_name
  service_name        = azurerm_spring_cloud_service.test.name
}


resource "azurerm_spring_cloud_container_deployment" "test" {
  name                = "acctest-scjdc92s8"
  spring_cloud_app_id = azurerm_spring_cloud_app.test.id
  server              = "docker.io"
  image               = "springio/gs-spring-boot-docker"
}


resource "azurerm_spring_cloud_container_deployment" "import" {
  name                = azurerm_spring_cloud_container_deployment.test.name
  spring_cloud_app_id = azurerm_spring_cloud_container_deployment.test.spring_cloud_app_id
  server              = "docker.io"
  image               = "springio/gs-spring-boot-docker"
}
