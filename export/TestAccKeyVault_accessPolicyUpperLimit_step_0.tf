
provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220623223517645204"
  location = "West Europe"
}

resource "azurerm_key_vault" "test" {
  name                       = "vault220623223517645204"
  location                   = azurerm_resource_group.test.location
  resource_group_name        = azurerm_resource_group.test.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7

  
access_policy {
  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = "${azurerm_storage_account.test1.identity.0.principal_id}"

  key_permissions    = ["Get", "Create", "Delete", "List", "Restore", "Recover", "UnwrapKey", "WrapKey", "Purge", "Encrypt", "Decrypt", "Sign", "Verify"]
  secret_permissions = ["Get"]
}

access_policy {
  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = "${azurerm_storage_account.test2.identity.0.principal_id}"

  key_permissions    = ["Get", "Create", "Delete", "List", "Restore", "Recover", "UnwrapKey", "WrapKey", "Purge", "Encrypt", "Decrypt", "Sign", "Verify"]
  secret_permissions = ["Get"]
}

access_policy {
  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = "${azurerm_storage_account.test3.identity.0.principal_id}"

  key_permissions    = ["Get", "Create", "Delete", "List", "Restore", "Recover", "UnwrapKey", "WrapKey", "Purge", "Encrypt", "Decrypt", "Sign", "Verify"]
  secret_permissions = ["Get"]
}

access_policy {
  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = "${azurerm_storage_account.test4.identity.0.principal_id}"

  key_permissions    = ["Get", "Create", "Delete", "List", "Restore", "Recover", "UnwrapKey", "WrapKey", "Purge", "Encrypt", "Decrypt", "Sign", "Verify"]
  secret_permissions = ["Get"]
}

access_policy {
  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = "${azurerm_storage_account.test5.identity.0.principal_id}"

  key_permissions    = ["Get", "Create", "Delete", "List", "Restore", "Recover", "UnwrapKey", "WrapKey", "Purge", "Encrypt", "Decrypt", "Sign", "Verify"]
  secret_permissions = ["Get"]
}

access_policy {
  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = "${azurerm_storage_account.test6.identity.0.principal_id}"

  key_permissions    = ["Get", "Create", "Delete", "List", "Restore", "Recover", "UnwrapKey", "WrapKey", "Purge", "Encrypt", "Decrypt", "Sign", "Verify"]
  secret_permissions = ["Get"]
}

access_policy {
  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = "${azurerm_storage_account.test7.identity.0.principal_id}"

  key_permissions    = ["Get", "Create", "Delete", "List", "Restore", "Recover", "UnwrapKey", "WrapKey", "Purge", "Encrypt", "Decrypt", "Sign", "Verify"]
  secret_permissions = ["Get"]
}

access_policy {
  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = "${azurerm_storage_account.test8.identity.0.principal_id}"

  key_permissions    = ["Get", "Create", "Delete", "List", "Restore", "Recover", "UnwrapKey", "WrapKey", "Purge", "Encrypt", "Decrypt", "Sign", "Verify"]
  secret_permissions = ["Get"]
}

access_policy {
  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = "${azurerm_storage_account.test9.identity.0.principal_id}"

  key_permissions    = ["Get", "Create", "Delete", "List", "Restore", "Recover", "UnwrapKey", "WrapKey", "Purge", "Encrypt", "Decrypt", "Sign", "Verify"]
  secret_permissions = ["Get"]
}

access_policy {
  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = "${azurerm_storage_account.test10.identity.0.principal_id}"

  key_permissions    = ["Get", "Create", "Delete", "List", "Restore", "Recover", "UnwrapKey", "WrapKey", "Purge", "Encrypt", "Decrypt", "Sign", "Verify"]
  secret_permissions = ["Get"]
}

access_policy {
  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = "${azurerm_storage_account.test11.identity.0.principal_id}"

  key_permissions    = ["Get", "Create", "Delete", "List", "Restore", "Recover", "UnwrapKey", "WrapKey", "Purge", "Encrypt", "Decrypt", "Sign", "Verify"]
  secret_permissions = ["Get"]
}

access_policy {
  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = "${azurerm_storage_account.test12.identity.0.principal_id}"

  key_permissions    = ["Get", "Create", "Delete", "List", "Restore", "Recover", "UnwrapKey", "WrapKey", "Purge", "Encrypt", "Decrypt", "Sign", "Verify"]
  secret_permissions = ["Get"]
}

access_policy {
  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = "${azurerm_storage_account.test13.identity.0.principal_id}"

  key_permissions    = ["Get", "Create", "Delete", "List", "Restore", "Recover", "UnwrapKey", "WrapKey", "Purge", "Encrypt", "Decrypt", "Sign", "Verify"]
  secret_permissions = ["Get"]
}

access_policy {
  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = "${azurerm_storage_account.test14.identity.0.principal_id}"

  key_permissions    = ["Get", "Create", "Delete", "List", "Restore", "Recover", "UnwrapKey", "WrapKey", "Purge", "Encrypt", "Decrypt", "Sign", "Verify"]
  secret_permissions = ["Get"]
}

access_policy {
  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = "${azurerm_storage_account.test15.identity.0.principal_id}"

  key_permissions    = ["Get", "Create", "Delete", "List", "Restore", "Recover", "UnwrapKey", "WrapKey", "Purge", "Encrypt", "Decrypt", "Sign", "Verify"]
  secret_permissions = ["Get"]
}

access_policy {
  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = "${azurerm_storage_account.test16.identity.0.principal_id}"

  key_permissions    = ["Get", "Create", "Delete", "List", "Restore", "Recover", "UnwrapKey", "WrapKey", "Purge", "Encrypt", "Decrypt", "Sign", "Verify"]
  secret_permissions = ["Get"]
}

access_policy {
  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = "${azurerm_storage_account.test17.identity.0.principal_id}"

  key_permissions    = ["Get", "Create", "Delete", "List", "Restore", "Recover", "UnwrapKey", "WrapKey", "Purge", "Encrypt", "Decrypt", "Sign", "Verify"]
  secret_permissions = ["Get"]
}

access_policy {
  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = "${azurerm_storage_account.test18.identity.0.principal_id}"

  key_permissions    = ["Get", "Create", "Delete", "List", "Restore", "Recover", "UnwrapKey", "WrapKey", "Purge", "Encrypt", "Decrypt", "Sign", "Verify"]
  secret_permissions = ["Get"]
}

access_policy {
  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = "${azurerm_storage_account.test19.identity.0.principal_id}"

  key_permissions    = ["Get", "Create", "Delete", "List", "Restore", "Recover", "UnwrapKey", "WrapKey", "Purge", "Encrypt", "Decrypt", "Sign", "Verify"]
  secret_permissions = ["Get"]
}

access_policy {
  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = "${azurerm_storage_account.test20.identity.0.principal_id}"

  key_permissions    = ["Get", "Create", "Delete", "List", "Restore", "Recover", "UnwrapKey", "WrapKey", "Purge", "Encrypt", "Decrypt", "Sign", "Verify"]
  secret_permissions = ["Get"]
}

}


resource "azurerm_storage_account" "test1" {
  name                     = "testsa77r661"
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
  name                     = "testsa77r662"
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
  name                     = "testsa77r663"
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
  name                     = "testsa77r664"
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
  name                     = "testsa77r665"
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
  name                     = "testsa77r666"
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
  name                     = "testsa77r667"
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
  name                     = "testsa77r668"
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
  name                     = "testsa77r669"
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
  name                     = "testsa77r6610"
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
  name                     = "testsa77r6611"
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
  name                     = "testsa77r6612"
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
  name                     = "testsa77r6613"
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
  name                     = "testsa77r6614"
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
  name                     = "testsa77r6615"
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
  name                     = "testsa77r6616"
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
  name                     = "testsa77r6617"
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
  name                     = "testsa77r6618"
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
  name                     = "testsa77r6619"
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
  name                     = "testsa77r6620"
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

