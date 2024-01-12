

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-spring-240112035205057197"
  location = "West Europe"
}

resource "azurerm_spring_cloud_service" "test" {
  name                = "acctest-sc-240112035205057197"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}


resource "azurerm_spring_cloud_app" "test" {
  name                = "acctest-sca-240112035205057197"
  resource_group_name = azurerm_spring_cloud_service.test.resource_group_name
  service_name        = azurerm_spring_cloud_service.test.name

  ingress_settings {
    session_affinity        = "Cookie"
    read_timeout_in_seconds = 700
    send_timeout_in_seconds = 700
    session_cookie_max_age  = 700
    backend_protocol        = "GRPC"
  }
}
