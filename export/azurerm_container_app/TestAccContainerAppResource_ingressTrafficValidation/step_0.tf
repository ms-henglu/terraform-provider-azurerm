

provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-CAE-240119024724257605"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctestLAW-240119024724257605"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}


resource "azurerm_container_app_environment" "test" {
  name                = "acctest-CAEnv240119024724257605"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}


resource "azurerm_container_app" "test" {
  name                         = "acctest-capp-240119024724257605"
  resource_group_name          = azurerm_resource_group.test.name
  container_app_environment_id = azurerm_container_app_environment.test.id
  revision_mode                = "Single"

  template {
    container {
      name   = "acctest-cont-240119024724257605"
      image  = "jackofallops/azure-containerapps-python-acctest:v0.0.1"
      cpu    = 0.25
      memory = "0.5Gi"
    }
  }

  ingress {
    allow_insecure_connections = true
    external_enabled           = true
    target_port                = 5000
    transport                  = "http"
	
    traffic_weight {
      percentage      = 50
    }
    traffic_weight {
      percentage      = 50
    }

  }
}
