
provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230707010515839381"
  location = "West Europe"
}

resource "azurerm_key_vault" "test" {
  name                       = "vault230707010515839381"
  location                   = azurerm_resource_group.test.location
  resource_group_name        = azurerm_resource_group.test.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7

  
access_policy {
  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = "${azurerm_storage_account.test1.identity.0.principal_id}"

  key_permissions    = ["Get", "Create", "Delete", "List", "Restore", "Recover", "UnwrapKey", "WrapKey", "Purge", "Encrypt", "Decrypt", "Sign", "Verify", "Release", "Rotate", "GetRotationPolicy", "SetRotationPolicy"]
  secret_permissions = ["Get"]
}

access_policy {
  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = "${azurerm_storage_account.test2.identity.0.principal_id}"

  key_permissions    = ["Get", "Create", "Delete", "List", "Restore", "Recover", "UnwrapKey", "WrapKey", "Purge", "Encrypt", "Decrypt", "Sign", "Verify", "Release", "Rotate", "GetRotationPolicy", "SetRotationPolicy"]
  secret_permissions = ["Get"]
}

access_policy {
  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = "${azurerm_storage_account.test3.identity.0.principal_id}"

  key_permissions    = ["Get", "Create", "Delete", "List", "Restore", "Recover", "UnwrapKey", "WrapKey", "Purge", "Encrypt", "Decrypt", "Sign", "Verify", "Release", "Rotate", "GetRotationPolicy", "SetRotationPolicy"]
  secret_permissions = ["Get"]
}

access_policy {
  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = "${azurerm_storage_account.test4.identity.0.principal_id}"

  key_permissions    = ["Get", "Create", "Delete", "List", "Restore", "Recover", "UnwrapKey", "WrapKey", "Purge", "Encrypt", "Decrypt", "Sign", "Verify", "Release", "Rotate", "GetRotationPolicy", "SetRotationPolicy"]
  secret_permissions = ["Get"]
}

access_policy {
  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = "${azurerm_storage_account.test5.identity.0.principal_id}"

  key_permissions    = ["Get", "Create", "Delete", "List", "Restore", "Recover", "UnwrapKey", "WrapKey", "Purge", "Encrypt", "Decrypt", "Sign", "Verify", "Release", "Rotate", "GetRotationPolicy", "SetRotationPolicy"]
  secret_permissions = ["Get"]
}

access_policy {
  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = "${azurerm_storage_account.test6.identity.0.principal_id}"

  key_permissions    = ["Get", "Create", "Delete", "List", "Restore", "Recover", "UnwrapKey", "WrapKey", "Purge", "Encrypt", "Decrypt", "Sign", "Verify", "Release", "Rotate", "GetRotationPolicy", "SetRotationPolicy"]
  secret_permissions = ["Get"]
}

access_policy {
  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = "${azurerm_storage_account.test7.identity.0.principal_id}"

  key_permissions    = ["Get", "Create", "Delete", "List", "Restore", "Recover", "UnwrapKey", "WrapKey", "Purge", "Encrypt", "Decrypt", "Sign", "Verify", "Release", "Rotate", "GetRotationPolicy", "SetRotationPolicy"]
  secret_permissions = ["Get"]
}

access_policy {
  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = "${azurerm_storage_account.test8.identity.0.principal_id}"

  key_permissions    = ["Get", "Create", "Delete", "List", "Restore", "Recover", "UnwrapKey", "WrapKey", "Purge", "Encrypt", "Decrypt", "Sign", "Verify", "Release", "Rotate", "GetRotationPolicy", "SetRotationPolicy"]
  secret_permissions = ["Get"]
}

access_policy {
  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = "${azurerm_storage_account.test9.identity.0.principal_id}"

  key_permissions    = ["Get", "Create", "Delete", "List", "Restore", "Recover", "UnwrapKey", "WrapKey", "Purge", "Encrypt", "Decrypt", "Sign", "Verify", "Release", "Rotate", "GetRotationPolicy", "SetRotationPolicy"]
  secret_permissions = ["Get"]
}

access_policy {
  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = "${azurerm_storage_account.test10.identity.0.principal_id}"

  key_permissions    = ["Get", "Create", "Delete", "List", "Restore", "Recover", "UnwrapKey", "WrapKey", "Purge", "Encrypt", "Decrypt", "Sign", "Verify", "Release", "Rotate", "GetRotationPolicy", "SetRotationPolicy"]
  secret_permissions = ["Get"]
}

access_policy {
  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = "${azurerm_storage_account.test11.identity.0.principal_id}"

  key_permissions    = ["Get", "Create", "Delete", "List", "Restore", "Recover", "UnwrapKey", "WrapKey", "Purge", "Encrypt", "Decrypt", "Sign", "Verify", "Release", "Rotate", "GetRotationPolicy", "SetRotationPolicy"]
  secret_permissions = ["Get"]
}

access_policy {
  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = "${azurerm_storage_account.test12.identity.0.principal_id}"

  key_permissions    = ["Get", "Create", "Delete", "List", "Restore", "Recover", "UnwrapKey", "WrapKey", "Purge", "Encrypt", "Decrypt", "Sign", "Verify", "Release", "Rotate", "GetRotationPolicy", "SetRotationPolicy"]
  secret_permissions = ["Get"]
}

access_policy {
  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = "${azurerm_storage_account.test13.identity.0.principal_id}"

  key_permissions    = ["Get", "Create", "Delete", "List", "Restore", "Recover", "UnwrapKey", "WrapKey", "Purge", "Encrypt", "Decrypt", "Sign", "Verify", "Release", "Rotate", "GetRotationPolicy", "SetRotationPolicy"]
  secret_permissions = ["Get"]
}

access_policy {
  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = "${azurerm_storage_account.test14.identity.0.principal_id}"

  key_permissions    = ["Get", "Create", "Delete", "List", "Restore", "Recover", "UnwrapKey", "WrapKey", "Purge", "Encrypt", "Decrypt", "Sign", "Verify", "Release", "Rotate", "GetRotationPolicy", "SetRotationPolicy"]
  secret_permissions = ["Get"]
}

access_policy {
  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = "${azurerm_storage_account.test15.identity.0.principal_id}"

  key_permissions    = ["Get", "Create", "Delete", "List", "Restore", "Recover", "UnwrapKey", "WrapKey", "Purge", "Encrypt", "Decrypt", "Sign", "Verify", "Release", "Rotate", "GetRotationPolicy", "SetRotationPolicy"]
  secret_permissions = ["Get"]
}

access_policy {
  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = "${azurerm_storage_account.test16.identity.0.principal_id}"

  key_permissions    = ["Get", "Create", "Delete", "List", "Restore", "Recover", "UnwrapKey", "WrapKey", "Purge", "Encrypt", "Decrypt", "Sign", "Verify", "Release", "Rotate", "GetRotationPolicy", "SetRotationPolicy"]
  secret_permissions = ["Get"]
}

access_policy {
  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = "${azurerm_storage_account.test17.identity.0.principal_id}"

  key_permissions    = ["Get", "Create", "Delete", "List", "Restore", "Recover", "UnwrapKey", "WrapKey", "Purge", "Encrypt", "Decrypt", "Sign", "Verify", "Release", "Rotate", "GetRotationPolicy", "SetRotationPolicy"]
  secret_permissions = ["Get"]
}

access_policy {
  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = "${azurerm_storage_account.test18.identity.0.principal_id}"

  key_permissions    = ["Get", "Create", "Delete", "List", "Restore", "Recover", "UnwrapKey", "WrapKey", "Purge", "Encrypt", "Decrypt", "Sign", "Verify", "Release", "Rotate", "GetRotationPolicy", "SetRotationPolicy"]
  secret_permissions = ["Get"]
}

access_policy {
  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = "${azurerm_storage_account.test19.identity.0.principal_id}"

  key_permissions    = ["Get", "Create", "Delete", "List", "Restore", "Recover", "UnwrapKey", "WrapKey", "Purge", "Encrypt", "Decrypt", "Sign", "Verify", "Release", "Rotate", "GetRotationPolicy", "SetRotationPolicy"]
  secret_permissions = ["Get"]
}

access_policy {
  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = "${azurerm_storage_account.test20.identity.0.principal_id}"

  key_permissions    = ["Get", "Create", "Delete", "List", "Restore", "Recover", "UnwrapKey", "WrapKey", "Purge", "Encrypt", "Decrypt", "Sign", "Verify", "Release", "Rotate", "GetRotationPolicy", "SetRotationPolicy"]
  secret_permissions = ["Get"]
}

}


resource "azurerm_storage_account" "test1" {
  name                     = "testsafy23l1"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  identity {
    type = "SystemAssigned"
  }

  tags = {
    environment = "testing"
  }
}

resource "azurerm_storage_account" "test2" {
  name                     = "testsafy23l2"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  identity {
    type = "SystemAssigned"
  }

  tags = {
    environment = "testing"
  }
}

resource "azurerm_storage_account" "test3" {
  name                     = "testsafy23l3"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  identity {
    type = "SystemAssigned"
  }

  tags = {
    environment = "testing"
  }
}

resource "azurerm_storage_account" "test4" {
  name                     = "testsafy23l4"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  identity {
    type = "SystemAssigned"
  }

  tags = {
    environment = "testing"
  }
}

resource "azurerm_storage_account" "test5" {
  name                     = "testsafy23l5"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  identity {
    type = "SystemAssigned"
  }

  tags = {
    environment = "testing"
  }
}

resource "azurerm_storage_account" "test6" {
  name                     = "testsafy23l6"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  identity {
    type = "SystemAssigned"
  }

  tags = {
    environment = "testing"
  }
}

resource "azurerm_storage_account" "test7" {
  name                     = "testsafy23l7"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  identity {
    type = "SystemAssigned"
  }

  tags = {
    environment = "testing"
  }
}

resource "azurerm_storage_account" "test8" {
  name                     = "testsafy23l8"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  identity {
    type = "SystemAssigned"
  }

  tags = {
    environment = "testing"
  }
}

resource "azurerm_storage_account" "test9" {
  name                     = "testsafy23l9"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  identity {
    type = "SystemAssigned"
  }

  tags = {
    environment = "testing"
  }
}

resource "azurerm_storage_account" "test10" {
  name                     = "testsafy23l10"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  identity {
    type = "SystemAssigned"
  }

  tags = {
    environment = "testing"
  }
}

resource "azurerm_storage_account" "test11" {
  name                     = "testsafy23l11"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  identity {
    type = "SystemAssigned"
  }

  tags = {
    environment = "testing"
  }
}

resource "azurerm_storage_account" "test12" {
  name                     = "testsafy23l12"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  identity {
    type = "SystemAssigned"
  }

  tags = {
    environment = "testing"
  }
}

resource "azurerm_storage_account" "test13" {
  name                     = "testsafy23l13"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  identity {
    type = "SystemAssigned"
  }

  tags = {
    environment = "testing"
  }
}

resource "azurerm_storage_account" "test14" {
  name                     = "testsafy23l14"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  identity {
    type = "SystemAssigned"
  }

  tags = {
    environment = "testing"
  }
}

resource "azurerm_storage_account" "test15" {
  name                     = "testsafy23l15"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  identity {
    type = "SystemAssigned"
  }

  tags = {
    environment = "testing"
  }
}

resource "azurerm_storage_account" "test16" {
  name                     = "testsafy23l16"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  identity {
    type = "SystemAssigned"
  }

  tags = {
    environment = "testing"
  }
}

resource "azurerm_storage_account" "test17" {
  name                     = "testsafy23l17"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  identity {
    type = "SystemAssigned"
  }

  tags = {
    environment = "testing"
  }
}

resource "azurerm_storage_account" "test18" {
  name                     = "testsafy23l18"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  identity {
    type = "SystemAssigned"
  }

  tags = {
    environment = "testing"
  }
}

resource "azurerm_storage_account" "test19" {
  name                     = "testsafy23l19"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  identity {
    type = "SystemAssigned"
  }

  tags = {
    environment = "testing"
  }
}

resource "azurerm_storage_account" "test20" {
  name                     = "testsafy23l20"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  identity {
    type = "SystemAssigned"
  }

  tags = {
    environment = "testing"
  }
}

