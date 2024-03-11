


provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }

    key_vault {
      purge_soft_delete_on_destroy       = false
      purge_soft_deleted_keys_on_destroy = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-netapp-240311032721757464"
  location = "West Europe"

  tags = {
    "SkipNRMSNSG" = "true"
  }
}


data "azurerm_client_config" "current" {
}

resource "azurerm_key_vault" "test" {
  name                            = "anfakv240311032721757464"
  location                        = azurerm_resource_group.test.location
  resource_group_name             = azurerm_resource_group.test.name
  enabled_for_disk_encryption     = true
  enabled_for_deployment          = true
  enabled_for_template_deployment = true
  purge_protection_enabled        = true
  tenant_id                       = "ARM_TENANT_ID"

  sku_name = "standard"
}

resource "azurerm_key_vault_access_policy" "test-currentuser" {
  key_vault_id = azurerm_key_vault.test.id
  tenant_id    = azurerm_netapp_account.test.identity.0.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  key_permissions = [
    "Get",
    "Create",
    "Delete",
    "WrapKey",
    "UnwrapKey",
    "GetRotationPolicy",
    "SetRotationPolicy",
  ]
}

resource "azurerm_key_vault_key" "test" {
  name         = "anfenckey240311032721757464"
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

  depends_on = [
    azurerm_key_vault_access_policy.test-currentuser
  ]
}

resource "azurerm_netapp_account" "test" {
  name                = "acctest-NetAppAccount-240311032721757464"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_key_vault_access_policy" "test-systemassigned" {
  key_vault_id = azurerm_key_vault.test.id
  tenant_id    = azurerm_netapp_account.test.identity.0.tenant_id
  object_id    = azurerm_netapp_account.test.identity.0.principal_id

  key_permissions = [
    "Get",
    "Encrypt",
    "Decrypt"
  ]
}

resource "azurerm_netapp_account_encryption" "test" {
  netapp_account_id = azurerm_netapp_account.test.id

  system_assigned_identity_principal_id = azurerm_netapp_account.test.identity.0.principal_id

  encryption_key = azurerm_key_vault_key.test.versionless_id

  depends_on = [
    azurerm_key_vault_access_policy.test-systemassigned
  ]
}



resource "azurerm_virtual_network" "test" {
  name                = "acctest-VirtualNetwork-240311032721757464"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  address_space       = ["10.6.0.0/16"]

  tags = {
    "CreatedOnDate"    = "2022-07-08T23:50:21Z",
    "SkipASMAzSecPack" = "true"
  }
}

resource "azurerm_subnet" "test-delegated" {
  name                 = "acctest-Delegated-Subnet-240311032721757464"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.6.1.0/24"]

  delegation {
    name = "testdelegation"

    service_delegation {
      name    = "Microsoft.Netapp/volumes"
      actions = ["Microsoft.Network/networkinterfaces/*", "Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

resource "azurerm_subnet" "test-non-delegated" {
  name                 = "acctest-Non-Delegated-Subnet-240311032721757464"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.6.0.0/24"]
}


resource "azurerm_private_endpoint" "test" {
  name                = "acctest-pe-akv-240311032721757464"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  subnet_id           = azurerm_subnet.test-non-delegated.id

  private_service_connection {
    name                           = "acctest-pe-sc-akv-240311032721757464"
    private_connection_resource_id = azurerm_key_vault.test.id
    is_manual_connection           = false
    subresource_names              = ["Vault"]
  }

  tags = {
    CreatedOnDate = "2023-10-03T19:58:43.6509795Z"
  }
}

resource "azurerm_netapp_pool" "test" {
  name                = "acctest-NetAppPool-240311032721757464"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  account_name        = azurerm_netapp_account.test.name
  service_level       = "Standard"
  size_in_tb          = 4

  tags = {
    "CreatedOnDate"    = "2022-07-08T23:50:21Z",
    "SkipASMAzSecPack" = "true"
  }

  depends_on = [
    azurerm_netapp_account_encryption.test
  ]
}

resource "azurerm_netapp_volume" "test" {
  name                          = "acctest-NetAppVolume-240311032721757464"
  location                      = azurerm_resource_group.test.location
  resource_group_name           = azurerm_resource_group.test.name
  account_name                  = azurerm_netapp_account.test.name
  pool_name                     = azurerm_netapp_pool.test.name
  volume_path                   = "my-unique-file-path-240311032721757464"
  service_level                 = "Standard"
  subnet_id                     = azurerm_subnet.test-delegated.id
  storage_quota_in_gb           = 100
  network_features              = "Standard"
  encryption_key_source         = "Microsoft.KeyVault"
  key_vault_private_endpoint_id = azurerm_private_endpoint.test.id

  tags = {
    "CreatedOnDate"    = "2022-07-08T23:50:21Z",
    "SkipASMAzSecPack" = "true"
  }

  depends_on = [
    azurerm_netapp_account_encryption.test,
    azurerm_private_endpoint.test
  ]
}
