

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
  name     = "acctestRG-230609091011695652"
  location = "West Europe"
}

resource "azurerm_key_vault" "test" {
  name                = "acctestkv-z7vci"
  location            = "${azurerm_resource_group.test.location}"
  resource_group_name = "${azurerm_resource_group.test.name}"
  tenant_id           = "${data.azurerm_client_config.current.tenant_id}"
  sku_name            = "standard"

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

  tags = {
    environment = "Production"
  }
}

resource "azurerm_key_vault_secret" "test" {
  name         = "secret-z7vci"
  value        = "szechuan"
  key_vault_id = azurerm_key_vault.test.id
}

resource "azurerm_key_vault_key" "test" {
  name         = "key-z7vci"
  key_vault_id = azurerm_key_vault.test.id
  key_type     = "EC"
  key_size     = 2048

  key_opts = [
    "sign",
    "verify",
  ]
}


resource "azurerm_key_vault" "test2" {
  name                = "acctestkv2-z7vci"
  location            = "${azurerm_resource_group.test.location}"
  resource_group_name = "${azurerm_resource_group.test.name}"
  tenant_id           = "${data.azurerm_client_config.current.tenant_id}"
  sku_name            = "standard"

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

resource "azurerm_key_vault_secret" "test2" {
  name         = "secret2-z7vci"
  value        = "szechuan"
  key_vault_id = azurerm_key_vault.test2.id
}

resource "azurerm_key_vault_key" "test2" {
  name         = "key2-z7vci"
  key_vault_id = azurerm_key_vault.test2.id
  key_type     = "EC"
  key_size     = 2048

  key_opts = [
    "sign",
    "verify",
  ]
}

resource "azurerm_managed_disk" "test" {
  name                 = "acctestd-230609091011695652"
  location             = "${azurerm_resource_group.test.location}"
  resource_group_name  = "${azurerm_resource_group.test.name}"
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "1"

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

  tags = {
    environment = "acctest"
    cost-center = "ops"
  }
}
