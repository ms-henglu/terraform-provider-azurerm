

provider "azurerm" {
  features {
    key_vault {
      recover_soft_deleted_key_vaults       = false
      purge_soft_delete_on_destroy          = false
      purge_soft_deleted_keys_on_destroy    = false
      purge_soft_deleted_secrets_on_destroy = false
    }
  }
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240112034043041396"
  location = "West Europe"
}

resource "azurerm_managed_disk" "test" {
  name                 = "acctestmd-240112034043041396"
  location             = "${azurerm_resource_group.test.location}"
  resource_group_name  = "${azurerm_resource_group.test.name}"
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "10"
}

resource "azurerm_key_vault" "test" {
  name                     = "acctestkvxiy9s"
  location                 = "${azurerm_resource_group.test.location}"
  resource_group_name      = "${azurerm_resource_group.test.name}"
  tenant_id                = "${data.azurerm_client_config.current.tenant_id}"
  purge_protection_enabled = true

  sku_name = "standard"

  access_policy {
    tenant_id = "${data.azurerm_client_config.current.tenant_id}"
    object_id = "${data.azurerm_client_config.current.object_id}"

    key_permissions = [
      "Create",
      "Delete",
      "Get",
      "Purge",
      "GetRotationPolicy",
    ]

    secret_permissions = [
      "Delete",
      "Get",
      "Set",
    ]
  }

  enabled_for_disk_encryption = true
}

resource "azurerm_key_vault_key" "test" {
  name         = "generated-certificate"
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
}

resource "azurerm_key_vault_secret" "test" {
  name         = "secret-sauce"
  value        = "szechuan"
  key_vault_id = azurerm_key_vault.test.id
}


resource "azurerm_key_vault" "test2" {
  name                     = "acctestkv2xiy9s"
  location                 = "${azurerm_resource_group.test.location}"
  resource_group_name      = "${azurerm_resource_group.test.name}"
  tenant_id                = "${data.azurerm_client_config.current.tenant_id}"
  purge_protection_enabled = true

  sku_name = "standard"

  access_policy {
    tenant_id = "${data.azurerm_client_config.current.tenant_id}"
    object_id = "${data.azurerm_client_config.current.object_id}"

    key_permissions = [
      "Create",
      "Delete",
      "Get",
      "Purge",
      "GetRotationPolicy",
    ]

    secret_permissions = [
      "Delete",
      "Get",
      "Set",
    ]
  }

  enabled_for_disk_encryption = true
}

resource "azurerm_key_vault_key" "test2" {
  name         = "generated-certificate"
  key_vault_id = azurerm_key_vault.test2.id
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
}

resource "azurerm_key_vault_secret" "test2" {
  name         = "secret-sauce"
  value        = "szechuan"
  key_vault_id = azurerm_key_vault.test2.id
}

resource "azurerm_snapshot" "test" {
  name                = "acctestss_240112034043041396"
  location            = "${azurerm_resource_group.test.location}"
  resource_group_name = "${azurerm_resource_group.test.name}"
  create_option       = "Copy"
  source_uri          = "${azurerm_managed_disk.test.id}"
  disk_size_gb        = "20"

  encryption_settings {
    disk_encryption_key {
      secret_url      = "${azurerm_key_vault_secret.test2.id}"
      source_vault_id = "${azurerm_key_vault.test2.id}"
    }

    key_encryption_key {
      key_url         = "${azurerm_key_vault_key.test2.id}"
      source_vault_id = "${azurerm_key_vault.test2.id}"
    }
  }
}
