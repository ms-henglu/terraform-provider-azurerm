

provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-CAE-240315122626543711"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctestLAW-240315122626543711"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}


resource "azurerm_container_app_environment" "test" {
  name                = "acctest-CAEnv240315122626543711"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}


resource "azurerm_container_app" "test" {
  name                         = "acctest-capp-240315122626543711"
  resource_group_name          = azurerm_resource_group.test.name
  container_app_environment_id = azurerm_container_app_environment.test.id
  revision_mode                = "Single"

  template {
    container {
      name   = "acctest-cont-240315122626543711"
      image  = "jackofallops/azure-containerapps-python-acctest:v0.0.1"
      cpu    = 0.25
      memory = "0.5Gi"
    }
  }

  ingress {
    target_port = 5000
    ip_security_restriction {
      name             = "test"
      description      = "test"
      action           = "Allow"
      ip_address_range = "10.1.0.0/16"
    }

    ip_security_restriction {
      name             = "test2"
      description      = "test2"
      action           = "Allow"
      ip_address_range = "10.2.0.0/16"
    }

    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }
}
