

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-spring-240119025843872500"
  location = "West Europe"
}

resource "azurerm_spring_cloud_service" "test" {
  name                = "acctest-sc-240119025843872500"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}


resource "azurerm_spring_cloud_app" "test" {
  name                = "acctest-sca-240119025843872500"
  resource_group_name = azurerm_spring_cloud_service.test.resource_group_name
  service_name        = azurerm_spring_cloud_service.test.name

  ingress_settings {
    session_affinity        = "None"
    read_timeout_in_seconds = 70
    send_timeout_in_seconds = 70
    session_cookie_max_age  = 0
    backend_protocol        = "Default"
  }
}
