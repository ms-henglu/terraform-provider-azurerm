

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-spring-221124182351150494"
  location = "West Europe"
}

resource "azurerm_spring_cloud_service" "test" {
  name                = "acctest-sc-221124182351150494"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "E0"
}

data "azurerm_client_config" "current" {
}

resource "azurerm_spring_cloud_gateway" "test" {
  name                    = "default"
  spring_cloud_service_id = azurerm_spring_cloud_service.test.id

  https_only                    = false
  public_network_access_enabled = true
  instance_count                = 2

  api_metadata {
    description       = "test description"
    documentation_url = "https://www.test.com/docs"
    server_url        = "https://www.test.com"
    title             = "test title"
    version           = "1.0"
  }

  cors {
    credentials_allowed = false
    allowed_headers     = ["*"]
    allowed_methods     = ["PUT"]
    allowed_origins     = ["test.com"]
    exposed_headers     = ["x-test-header"]
    max_age_seconds     = 86400
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
