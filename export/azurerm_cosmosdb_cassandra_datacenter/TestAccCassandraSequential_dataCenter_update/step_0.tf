

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy       = false
      purge_soft_deleted_keys_on_destroy = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-cassandra-240119021821165632"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctvn-240119021821165632"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "test" {
  name                 = "acctsub-240119021821165632"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.1.0/24"]
}

data "azuread_service_principal" "test" {
  display_name = "Azure Cosmos DB"
}

resource "azurerm_role_assignment" "test" {
  scope                = azurerm_virtual_network.test.id
  role_definition_name = "Network Contributor"
  principal_id         = data.azuread_service_principal.test.object_id
}

resource "azurerm_cosmosdb_cassandra_cluster" "test" {
  name                           = "acctca-mi-cluster-240119021821165632"
  resource_group_name            = azurerm_resource_group.test.name
  location                       = azurerm_resource_group.test.location
  delegated_management_subnet_id = azurerm_subnet.test.id
  default_admin_password         = "Password1234"

  identity {
    type = "SystemAssigned"
  }

  depends_on = [azurerm_role_assignment.test]
}


data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "test" {
  name                       = "acctestkv-2ud0l"
  location                   = azurerm_resource_group.test.location
  resource_group_name        = azurerm_resource_group.test.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7
  purge_protection_enabled   = true
}

resource "azurerm_key_vault_access_policy" "current_user" {
  key_vault_id = azurerm_key_vault.test.id

  tenant_id = azurerm_key_vault.test.tenant_id
  object_id = data.azurerm_client_config.current.object_id

  key_permissions = [
    "Create",
    "Delete",
    "Get",
    "Purge",
    "Recover",
    "Update",
    "WrapKey",
    "UnwrapKey",
    "GetRotationPolicy"
  ]
}

resource "azurerm_key_vault_access_policy" "system_identity" {
  key_vault_id = azurerm_key_vault.test.id

  tenant_id = azurerm_key_vault.test.tenant_id
  object_id = azurerm_cosmosdb_cassandra_cluster.test.identity.0.principal_id

  key_permissions = [
    "Create",
    "Delete",
    "Get",
    "Purge",
    "Recover",
    "Update",
    "WrapKey",
    "UnwrapKey",
    "GetRotationPolicy"
  ]
}

resource "azurerm_key_vault_key" "test" {
  name         = "acctestkey-2ud0l"
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
    azurerm_key_vault_access_policy.current_user,
    azurerm_key_vault_access_policy.system_identity
  ]
}

resource "azurerm_cosmosdb_cassandra_datacenter" "test" {
  name                            = "acctca-mi-dc-240119021821165632"
  cassandra_cluster_id            = azurerm_cosmosdb_cassandra_cluster.test.id
  location                        = azurerm_cosmosdb_cassandra_cluster.test.location
  delegated_management_subnet_id  = azurerm_subnet.test.id
  node_count                      = 3
  disk_count                      = 4
  sku_name                        = "Standard_DS14_v2"
  availability_zones_enabled      = false
  disk_sku                        = "P30"
  backup_storage_customer_key_uri = azurerm_key_vault_key.test.id
  managed_disk_customer_key_uri   = azurerm_key_vault_key.test.id
  base64_encoded_yaml_fragment    = "Y29tcGFjdGlvbl90aHJvdWdocHV0X21iX3Blcl9zZWM6IDMyCmNvbXBhY3Rpb25fbGFyZ2VfcGFydGl0aW9uX3dhcm5pbmdfdGhyZXNob2xkX21iOiAxMDA="

  depends_on = [
    azurerm_key_vault_key.test
  ]
}
