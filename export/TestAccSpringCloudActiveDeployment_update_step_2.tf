

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-spring-220916012050799590"
  location = "West Europe"
}

resource "azurerm_spring_cloud_service" "test" {
  name                = "acctest-sc-220916012050799590"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_spring_cloud_app" "test" {
  name                = "acctest-sca-220916012050799590"
  resource_group_name = azurerm_spring_cloud_service.test.resource_group_name
  service_name        = azurerm_spring_cloud_service.test.name
}

resource "azurerm_spring_cloud_java_deployment" "test" {
  name                = "acctest-scjd10420"
  spring_cloud_app_id = azurerm_spring_cloud_app.test.id
}


resource "azurerm_spring_cloud_java_deployment" "test2" {
  name                = "acctest-scjd210420"
  spring_cloud_app_id = azurerm_spring_cloud_app.test.id
}

resource "azurerm_spring_cloud_active_deployment" "test" {
  spring_cloud_app_id = azurerm_spring_cloud_app.test.id
  deployment_name     = azurerm_spring_cloud_java_deployment.test2.name
}
