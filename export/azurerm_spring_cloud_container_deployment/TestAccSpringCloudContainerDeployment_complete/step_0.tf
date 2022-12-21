

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-spring-221221204858665490"
  location = "West Europe"
}

resource "azurerm_spring_cloud_service" "test" {
  name                = "acctest-sc-221221204858665490"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "E0"
}

resource "azurerm_spring_cloud_app" "test" {
  name                = "acctest-sca-221221204858665490"
  resource_group_name = azurerm_spring_cloud_service.test.resource_group_name
  service_name        = azurerm_spring_cloud_service.test.name
}


resource "azurerm_spring_cloud_container_deployment" "test" {
  name                = "acctest-scjdhzpqi"
  spring_cloud_app_id = azurerm_spring_cloud_app.test.id
  instance_count      = 2
  arguments           = ["-cp", "/app/resources:/app/classes:/app/libs/*", "hello.Application"]
  commands            = ["java"]
  environment_variables = {
    "Foo" : "Bar"
    "Env" : "Staging"
  }
  server             = "docker.io"
  image              = "springio/gs-spring-boot-docker"
  language_framework = "springboot"
}
