
provider azurerm {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-CAE-240315122626527778"
  location = "West Europe"
}

data "azurerm_dns_zone" "test" {
  name                = "ARM_TEST_DNS_ZONE"
  resource_group_name = "ARM_TEST_DATA_RESOURCE_GROUP"
}

resource "azurerm_dns_txt_record" "test" {
  name                = "asuid.containerapp240315122626527778"
  resource_group_name = data.azurerm_dns_zone.test.resource_group_name
  zone_name           = data.azurerm_dns_zone.test.name
  ttl                 = 300

  record {
    value = azurerm_container_app.test.custom_domain_verification_id
  }
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctestCAEnv-240315122626527778"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_container_app_environment" "test" {
  name                       = "acctest-CAEnv240315122626527778"
  resource_group_name        = azurerm_resource_group.test.name
  location                   = azurerm_resource_group.test.location
  log_analytics_workspace_id = azurerm_log_analytics_workspace.test.id
}

resource "azurerm_container_app_environment_certificate" "test" {
  name                         = "acctest-cacert240315122626527778"
  container_app_environment_id = azurerm_container_app_environment.test.id
  certificate_blob_base64      = filebase64("testdata/testacc.pfx")
  certificate_password         = "TestAcc"
}

resource "azurerm_container_app" "test" {
  name                         = "acctest-capp-240315122626527778"
  resource_group_name          = azurerm_resource_group.test.name
  container_app_environment_id = azurerm_container_app_environment.test.id
  revision_mode                = "Single"

  template {
    container {
      name   = "acctest-cont-240315122626527778"
      image  = "jackofallops/azure-containerapps-python-acctest:v0.0.1"
      cpu    = 0.25
      memory = "0.5Gi"
    }
  }

  ingress {
    allow_insecure_connections = false
    external_enabled           = true
    target_port                = 5000
    transport                  = "http"
    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }
}



resource "azurerm_container_app_custom_domain" "test" {
  name                                     = trimprefix(azurerm_dns_txt_record.test.fqdn, "asuid.")
  container_app_id                         = azurerm_container_app.test.id
  container_app_environment_certificate_id = azurerm_container_app_environment_certificate.test.id
  certificate_binding_type                 = "SniEnabled"
}

