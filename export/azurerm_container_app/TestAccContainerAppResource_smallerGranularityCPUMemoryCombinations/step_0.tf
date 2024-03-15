

provider "azurerm" {
  features {}
}





resource "azurerm_resource_group" "test" {
  name     = "acctestRG-CAE-240315122626532962"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctestLAW-240315122626532962"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}


resource "azurerm_virtual_network" "test" {
  name                = "acctestvirtnet240315122626532962"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "control" {
  name                 = "control-plane"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.0.0/23"]

  delegation {
    name = "acctestdelegation240315122626532962"
    service_delegation {
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
      name    = "Microsoft.App/environments"
    }
  }
}




resource "azurerm_container_app_environment" "test" {
  name                       = "acctest-CAEnv240315122626532962"
  resource_group_name        = azurerm_resource_group.test.name
  location                   = azurerm_resource_group.test.location
  log_analytics_workspace_id = azurerm_log_analytics_workspace.test.id
  infrastructure_subnet_id   = azurerm_subnet.control.id

  internal_load_balancer_enabled = true
  zone_redundancy_enabled        = true

  workload_profile {
    maximum_count         = 3
    minimum_count         = 0
    name                  = "D4-01"
    workload_profile_type = "D4"
  }

  tags = {
    Foo    = "Bar"
    secret = "sauce"
  }
}


locals {
  workload_profiles = tolist(azurerm_container_app_environment.test.workload_profile)
}

resource "azurerm_container_app" "test" {
  name                         = "acctest-capp-240315122626532962"
  resource_group_name          = azurerm_resource_group.test.name
  container_app_environment_id = azurerm_container_app_environment.test.id
  revision_mode                = "Single"

  workload_profile_name = local.workload_profiles.0.name

  template {
    container {
      name   = "acctest-cont-240315122626532962"
      image  = "jackofallops/azure-containerapps-python-acctest:v0.0.1"
      cpu    = 0.1
      memory = "0.4Gi"
    }

    init_container {
      name   = "init-cont-240315122626532962"
      image  = "jackofallops/azure-containerapps-python-acctest:v0.0.1"
      cpu    = 0.1
      memory = "0.2Gi"
    }
  }

  ingress {
    allow_insecure_connections = true
    external_enabled           = true
    target_port                = 5000
    transport                  = "http"
    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }

  tags = {
    foo     = "Bar"
    accTest = "1"
  }
}
