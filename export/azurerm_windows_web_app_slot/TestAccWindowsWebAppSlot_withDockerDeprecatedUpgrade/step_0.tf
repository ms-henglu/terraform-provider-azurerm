
provider "azurerm" {
  features {}
}



resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230810142912365929"
  location = "West Europe"
}

resource "azurerm_service_plan" "test" {
  name                = "acctestASP-230810142912365929"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "P1v3"
  os_type             = "WindowsContainer"
}

resource "azurerm_windows_web_app" "test" {
  name                = "acctestWA-230810142912365929"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  service_plan_id     = azurerm_service_plan.test.id

  app_settings = {
    "DOCKER_REGISTRY_SERVER_URL"          = "https://index.docker.io"
    "DOCKER_REGISTRY_SERVER_USERNAME"     = ""
    "DOCKER_REGISTRY_SERVER_PASSWORD"     = ""
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "false"
  }

  site_config {
    application_stack {
      docker_container_name = "traefik"
      docker_container_tag  = "windowsservercore-1809"
    }
  }
}


resource "azurerm_windows_web_app_slot" "test" {
  name           = "acctestWAS-230810142912365929"
  app_service_id = azurerm_windows_web_app.test.id

  app_settings = {
    "DOCKER_REGISTRY_SERVER_URL"          = "https://index.docker.io"
    "DOCKER_REGISTRY_SERVER_USERNAME"     = ""
    "DOCKER_REGISTRY_SERVER_PASSWORD"     = ""
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "false"
  }

  site_config {
    application_stack {
      docker_container_name = "traefik"
      docker_container_tag  = "windowsservercore-1809"
    }
  }
}
