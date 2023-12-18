
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-databricks-231218071600784395"
  location = "West US 2"
}

resource "azurerm_application_insights" "test" {
  name                = "acctest-ai-231218071600784395"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  application_type    = "web"
}

resource "azurerm_key_vault" "test" {
  name                = "acctest-kv-mm2wc"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "premium"

  purge_protection_enabled   = true
  soft_delete_retention_days = 7
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsamm2wc"
  location                 = azurerm_resource_group.test.location
  resource_group_name      = azurerm_resource_group.test.name
  account_tier             = "Standard"
  account_replication_type = "LRS"

  static_website {
    error_404_document = "error.html"
    index_document     = "index.html"
  }
}

resource "azurerm_machine_learning_workspace" "test" {
  name                    = "acctest-mlws-231218071600784395"
  location                = azurerm_resource_group.test.location
  resource_group_name     = azurerm_resource_group.test.name
  application_insights_id = azurerm_application_insights.test.id
  key_vault_id            = azurerm_key_vault.test.id
  storage_account_id      = azurerm_storage_account.test.id

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_databricks_workspace" "test" {
  name                = "acctestDBW-231218071600784395"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "standard"

  custom_parameters {
    machine_learning_workspace_id = azurerm_machine_learning_workspace.test.id
  }
}
