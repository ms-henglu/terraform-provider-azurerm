


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-spring-240119025843897355"
  location = "West Europe"
}

resource "azurerm_spring_cloud_service" "test" {
  name                = "acctest-sc-240119025843897355"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_spring_cloud_app" "test" {
  name                = "acctest-sca-240119025843897355"
  resource_group_name = azurerm_spring_cloud_service.test.resource_group_name
  service_name        = azurerm_spring_cloud_service.test.name
}


resource "azurerm_spring_cloud_java_deployment" "test" {
  name                = "acctest-scjd46hak"
  spring_cloud_app_id = azurerm_spring_cloud_app.test.id
}


resource "azurerm_spring_cloud_java_deployment" "import" {
  name                = azurerm_spring_cloud_java_deployment.test.name
  spring_cloud_app_id = azurerm_spring_cloud_java_deployment.test.spring_cloud_app_id
}
