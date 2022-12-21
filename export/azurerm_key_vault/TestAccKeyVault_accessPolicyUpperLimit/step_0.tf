
provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221221204423530067"
  location = "West Europe"
}

resource "azurerm_key_vault" "test" {
  name                       = "vault221221204423530067"
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
  name                     = "testsa20bl41"
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
  name                     = "testsa20bl42"
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
  name                     = "testsa20bl43"
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
  name                     = "testsa20bl44"
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
  name                     = "testsa20bl45"
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
  name                     = "testsa20bl46"
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
  name                     = "testsa20bl47"
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
  name                     = "testsa20bl48"
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
  name                     = "testsa20bl49"
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
  name                     = "testsa20bl410"
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
  name                     = "testsa20bl411"
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
  name                     = "testsa20bl412"
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
  name                     = "testsa20bl413"
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
  name                     = "testsa20bl414"
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
  name                     = "testsa20bl415"
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
  name                     = "testsa20bl416"
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
  name                     = "testsa20bl417"
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
  name                     = "testsa20bl418"
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
  name                     = "testsa20bl419"
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
  name                     = "testsa20bl420"
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

