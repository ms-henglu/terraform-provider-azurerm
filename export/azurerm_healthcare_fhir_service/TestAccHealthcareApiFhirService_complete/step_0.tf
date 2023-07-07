
data "azurerm_client_config" "current" {
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-healthcareapi-230707004009277012"
  location = "West Europe"
}

resource "azurerm_healthcare_workspace" "test" {
  name                = "acc230707004009277012"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}


resource "azurerm_container_registry" "test" {
  name                = "acc230707004009277012"
  resource_group_name = azurerm_resource_group.test.name
  location            = "West Europe"
  sku                 = "Premium"
  admin_enabled       = false

  georeplications {
    location                = "West US 2"
    zone_redundancy_enabled = true
    tags                    = {}
  }
}

resource "azurerm_storage_account" "test" {
  name                     = "acc230707004009277012"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  tags = {
    environment = "staging"
  }
}

resource "azurerm_healthcare_fhir_service" "test" {
  name                = "fhir230707004009277012"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  workspace_id        = azurerm_healthcare_workspace.test.id
  kind                = "fhir-R4"

  authentication {
    authority = "https://login.microsoftonline.com/72f988bf-86f1-41af-91ab-2d7cd011db47"
    audience  = "https://acctestfhir.fhir.azurehealthcareapis.com"
  }

  access_policy_object_ids = [
    data.azurerm_client_config.current.object_id
  ]

  identity {
    type = "SystemAssigned"
  }

  container_registry_login_server_url = [azurerm_container_registry.test.login_server]

  oci_artifact {
    login_server = azurerm_container_registry.test.login_server
  }

  cors {
    allowed_origins     = ["https://acctest.com:123", "https://acctest1.com:3389"]
    allowed_headers     = ["*"]
    allowed_methods     = ["GET", "DELETE", "PUT"]
    max_age_in_seconds  = 3600
    credentials_allowed = true
  }

  configuration_export_storage_account_name = azurerm_storage_account.test.name
}
