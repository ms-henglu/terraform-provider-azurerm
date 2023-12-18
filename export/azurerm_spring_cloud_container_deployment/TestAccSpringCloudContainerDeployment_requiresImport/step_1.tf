


provider "azurerm" {
  features {
    application_insights {
      disable_generated_rule = true
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-spring-231218072610919298"
  location = "West Europe"
}

resource "azurerm_spring_cloud_service" "test" {
  name                = "acctest-sc-231218072610919298"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "E0"
}

resource "azurerm_spring_cloud_app" "test" {
  name                = "acctest-sca-231218072610919298"
  resource_group_name = azurerm_spring_cloud_service.test.resource_group_name
  service_name        = azurerm_spring_cloud_service.test.name
}


resource "azurerm_application_insights" "test" {
  name                = "acctest-ai-231218072610919298"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  application_type    = "web"
}

resource "azurerm_spring_cloud_application_insights_application_performance_monitoring" "test" {
  name                    = "acctest-apm-231218072610919298"
  spring_cloud_service_id = azurerm_spring_cloud_service.test.id
  connection_string       = azurerm_application_insights.test.instrumentation_key
}


resource "azurerm_spring_cloud_container_deployment" "test" {
  name                = "acctest-scjdxd9wq"
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
