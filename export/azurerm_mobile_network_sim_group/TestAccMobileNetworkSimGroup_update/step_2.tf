
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctest-mn-231020041451033658"
  location = "West Europe"
}

resource "azurerm_mobile_network" "test" {
  name                = "acctest-mn-231020041451033658"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  mobile_country_code = "001"
  mobile_network_code = "01"
}


data "azurerm_client_config" "test" {}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctest-mn-231020041451033658"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_key_vault" "test" {
  name                = "acct-231020041451033658"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  tenant_id           = data.azurerm_client_config.test.tenant_id
  sku_name            = "standard"

  access_policy {
    tenant_id          = data.azurerm_client_config.test.tenant_id
    object_id          = data.azurerm_client_config.test.object_id
    secret_permissions = ["Delete", "Get", "Set"]
    key_permissions    = ["Create", "Delete", "Get", "Import", "Purge", "GetRotationPolicy"]
  }

  access_policy {
    tenant_id          = data.azurerm_client_config.test.tenant_id
    object_id          = azurerm_user_assigned_identity.test.principal_id
    secret_permissions = ["Delete", "Get", "Set"]
    key_permissions    = ["Create", "Delete", "Get", "Import", "Purge", "UnwrapKey", "WrapKey", "GetRotationPolicy"]
  }
}


resource "azurerm_key_vault_key" "test" {
  name         = "enckey231020041451033658"
  key_vault_id = "${azurerm_key_vault.test.id}"
  key_type     = "RSA"
  key_size     = 2048

  key_opts = ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey"]
}


resource "azurerm_mobile_network_sim_group" "test" {
  name               = "acctest-mnsg-231020041451033658"
  location           = azurerm_mobile_network.test.location
  mobile_network_id  = azurerm_mobile_network.test.id
  encryption_key_url = azurerm_key_vault_key.test.versionless_id

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.test.id]
  }

  tags = {
    key = "updated"
  }
}
