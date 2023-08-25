

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy       = false
      purge_soft_deleted_keys_on_destroy = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-spring-230825025330349188"
  location = "West Europe"
}

resource "azurerm_spring_cloud_service" "test" {
  name                = "acctest-sc-230825025330349188"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "E0"
}

data "azurerm_client_config" "current" {
}

resource "azurerm_spring_cloud_gateway" "test" {
  name                    = "default"
  spring_cloud_service_id = azurerm_spring_cloud_service.test.id

  https_only                               = false
  public_network_access_enabled            = false
  instance_count                           = 2
  application_performance_monitoring_types = ["ApplicationInsights", "NewRelic"]

  api_metadata {
    description       = "test description"
    documentation_url = "https://www.test.com/docs"
    server_url        = "https://www.test.com"
    title             = "test title"
    version           = "1.0"
  }

  cors {
    credentials_allowed     = false
    allowed_headers         = ["*"]
    allowed_methods         = ["PUT"]
    allowed_origins         = ["test.com"]
    allowed_origin_patterns = ["test*.com"]
    exposed_headers         = ["x-test-header"]
    max_age_seconds         = 86400
  }

  environment_variables = {
    APPLICATIONINSIGHTS_SAMPLE_RATE = "10"
  }

  sensitive_environment_variables = {
    NEW_RELIC_APP_NAME = "scg-asa"
  }

  quota {
    cpu    = "1"
    memory = "2Gi"
  }

  sso {
    client_id     = "ARM_CLIENT_ID"
    client_secret = "ARM_CLIENT_SECRET"
    issuer_uri    = "https://login.microsoftonline.com/${data.azurerm_client_config.current.tenant_id}/v2.0"
    scope         = ["read"]
  }
}
