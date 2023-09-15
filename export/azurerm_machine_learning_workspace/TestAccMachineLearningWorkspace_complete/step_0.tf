

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy       = false
      purge_soft_deleted_keys_on_destroy = false
    }
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-ml-230915023710435606"
  location = "West Europe"
}

resource "azurerm_application_insights" "test" {
  name                = "acctestai-230915023710435606"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  application_type    = "web"
}

resource "azurerm_key_vault" "test" {
  name                = "acctestvaultl7zpx"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  tenant_id           = data.azurerm_client_config.current.tenant_id

  sku_name = "standard"

  purge_protection_enabled = true
}

resource "azurerm_key_vault_access_policy" "test" {
  key_vault_id = azurerm_key_vault.test.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  key_permissions = [
    "Create",
    "Get",
    "Delete",
    "Purge",
    "GetRotationPolicy",
  ]
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsa230915023710406"
  location                 = azurerm_resource_group.test.location
  resource_group_name      = azurerm_resource_group.test.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}


resource "azurerm_container_registry" "test" {
  name                = "acctestacr2309150237104356"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Standard"
  admin_enabled       = true
}

resource "azurerm_key_vault_key" "test" {
  name         = "acctest-kv-key-2309150237104356"
  key_vault_id = azurerm_key_vault.test.id
  key_type     = "RSA"
  key_size     = 2048

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]

  depends_on = [azurerm_key_vault.test, azurerm_key_vault_access_policy.test]
}

resource "azurerm_machine_learning_workspace" "test" {
  name                          = "acctest-MLW-2309150237104356"
  location                      = azurerm_resource_group.test.location
  resource_group_name           = azurerm_resource_group.test.name
  friendly_name                 = "test-workspace"
  description                   = "Test machine learning workspace"
  application_insights_id       = azurerm_application_insights.test.id
  key_vault_id                  = azurerm_key_vault.test.id
  storage_account_id            = azurerm_storage_account.test.id
  container_registry_id         = azurerm_container_registry.test.id
  sku_name                      = "Basic"
  high_business_impact          = true
  public_network_access_enabled = true
  image_build_compute_name      = "terraformCompute"
  v1_legacy_mode_enabled        = false

  identity {
    type = "SystemAssigned"
  }

  encryption {
    key_vault_id = azurerm_key_vault.test.id
    key_id       = azurerm_key_vault_key.test.id
  }

  tags = {
    ENV = "Test"
  }
}
