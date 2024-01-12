

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-spring-240112035205069935"
  location = "West Europe"
}

resource "azurerm_spring_cloud_service" "test" {
  name                = "acctest-sc-240112035205069935"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "E0"
}

resource "azurerm_spring_cloud_app" "test" {
  name                = "acctest-sca-240112035205069935"
  resource_group_name = azurerm_spring_cloud_service.test.resource_group_name
  service_name        = azurerm_spring_cloud_service.test.name
}


resource "azurerm_application_insights" "test" {
  name                = "acctest-ai-240112035205069935"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  application_type    = "web"
}

resource "azurerm_spring_cloud_application_insights_application_performance_monitoring" "test" {
  name                    = "acctest-apm-240112035205069935"
  spring_cloud_service_id = azurerm_spring_cloud_service.test.id
  connection_string       = azurerm_application_insights.test.instrumentation_key
}


resource "azurerm_spring_cloud_container_deployment" "test" {
  name                                   = "acctest-scjdvsved"
  spring_cloud_app_id                    = azurerm_spring_cloud_app.test.id
  instance_count                         = 2
  arguments                              = ["-cp", "/app/resources:/app/classes:/app/libs/*", "hello.Application"]
  application_performance_monitoring_ids = [azurerm_spring_cloud_application_insights_application_performance_monitoring.test.id]
  commands                               = ["java"]
  environment_variables = {
    "Foo" : "Bar"
    "Env" : "Staging"
  }
  server             = "docker.io"
  image              = "springio/gs-spring-boot-docker"
  language_framework = "springboot"
}
