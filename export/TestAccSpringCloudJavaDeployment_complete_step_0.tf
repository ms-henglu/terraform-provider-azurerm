

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-spring-220916012050804484"
  location = "West Europe"
}

resource "azurerm_spring_cloud_service" "test" {
  name                = "acctest-sc-220916012050804484"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_spring_cloud_app" "test" {
  name                = "acctest-sca-220916012050804484"
  resource_group_name = azurerm_spring_cloud_service.test.resource_group_name
  service_name        = azurerm_spring_cloud_service.test.name
}


resource "azurerm_spring_cloud_java_deployment" "test" {
  name                = "acctest-scjdhnm6j"
  spring_cloud_app_id = azurerm_spring_cloud_app.test.id
  instance_count      = 2
  jvm_options         = "-XX:+PrintGC"
  runtime_version     = "Java_11"
  quota {
    cpu    = "2"
    memory = "2Gi"
  }
  environment_variables = {
    "Foo" : "Bar"
    "Env" : "Staging"
  }
}
