

provider "azurerm" {
  skip_provider_registration = true
  features {
    key_vault {
      recover_soft_deleted_key_vaults    = false
      purge_soft_delete_on_destroy       = false
      purge_soft_deleted_keys_on_destroy = false
    }
  }
}

provider "azuread" {}

data "azurerm_client_config" "test" {}

data "azuread_client_config" "test" {}

resource "azuread_application" "test" {
  display_name = "acctest-aro-240315123909741029"
}

resource "azuread_service_principal" "test" {
  application_id = azuread_application.test.application_id
}

resource "azuread_service_principal_password" "test" {
  service_principal_id = azuread_service_principal.test.object_id
}

data "azuread_service_principal" "redhatopenshift" {
  // This is the Azure Red Hat OpenShift RP service principal id, do NOT delete it
  application_id = "f1dd0a37-89c6-4e07-bcd1-ffd3d43d8875"
}

resource "azurerm_role_assignment" "role_network1" {
  scope                = azurerm_virtual_network.test.id
  role_definition_name = "Network Contributor"
  principal_id         = azuread_service_principal.test.object_id
}

resource "azurerm_role_assignment" "role_network2" {
  scope                = azurerm_virtual_network.test.id
  role_definition_name = "Network Contributor"
  principal_id         = data.azuread_service_principal.redhatopenshift.object_id
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-aro-240315123909741029"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestvirtnet240315123909741029"
  address_space       = ["10.0.0.0/22"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "main_subnet" {
  name                 = "main-subnet-240315123909741029"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.0.0/23"]
  service_endpoints    = ["Microsoft.Storage", "Microsoft.ContainerRegistry"]
}

resource "azurerm_subnet" "worker_subnet" {
  name                 = "worker-subnet-240315123909741029"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.2.0/23"]
  service_endpoints    = ["Microsoft.Storage", "Microsoft.ContainerRegistry"]
}
 

resource "azurerm_key_vault" "test" {
  name                        = "acctestKV-yt4m0"
  location                    = azurerm_resource_group.test.location
  resource_group_name         = azurerm_resource_group.test.name
  tenant_id                   = data.azurerm_client_config.test.tenant_id
  sku_name                    = "premium"
  enabled_for_disk_encryption = true
  purge_protection_enabled    = true
}

resource "azurerm_key_vault_access_policy" "service-principal" {
  key_vault_id = azurerm_key_vault.test.id
  tenant_id    = data.azurerm_client_config.test.tenant_id
  object_id    = data.azurerm_client_config.test.object_id

  key_permissions = [
    "Create",
    "Delete",
    "Get",
    "GetRotationPolicy",
    "Purge",
    "Update",
  ]
}

resource "azurerm_key_vault_key" "test" {
  name         = "acctestkvkeyyt4m0"
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
    azurerm_key_vault_access_policy.service-principal
  ]
}

resource "azurerm_disk_encryption_set" "test" {
  name                = "acctestdes-240315123909741029"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  key_vault_key_id    = azurerm_key_vault_key.test.id

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_key_vault_access_policy" "disk_encryption" {
  key_vault_id = azurerm_key_vault.test.id
  tenant_id    = azurerm_disk_encryption_set.test.identity.0.tenant_id
  object_id    = azurerm_disk_encryption_set.test.identity.0.principal_id

  key_permissions = [
    "Get",
    "WrapKey",
    "UnwrapKey"
  ]
}

resource "azurerm_role_assignment" "disk_encryption_reader1" {
  scope                = azurerm_disk_encryption_set.test.id
  role_definition_name = "Reader"
  principal_id         = azuread_service_principal.test.object_id
}

resource "azurerm_role_assignment" "disk_encryption_reader2" {
  scope                = azurerm_disk_encryption_set.test.id
  role_definition_name = "Reader"
  principal_id         = data.azuread_service_principal.redhatopenshift.object_id
}

resource "azurerm_redhat_openshift_cluster" "test" {
  name                = "acctestaro240315123909741029"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  cluster_profile {
    domain  = "aro-yt4m0.com"
    version = "4.13.23"
  }

  network_profile {
    pod_cidr     = "10.128.0.0/14"
    service_cidr = "172.30.0.0/16"
  }

  api_server_profile {
    visibility = "Public"
  }

  ingress_profile {
    visibility = "Public"
  }

  main_profile {
    vm_size                    = "Standard_D8s_v3"
    subnet_id                  = azurerm_subnet.main_subnet.id
    encryption_at_host_enabled = true
    disk_encryption_set_id     = azurerm_disk_encryption_set.test.id
  }

  worker_profile {
    vm_size                    = "Standard_D4s_v3"
    disk_size_gb               = 128
    node_count                 = 3
    subnet_id                  = azurerm_subnet.worker_subnet.id
    encryption_at_host_enabled = true
    disk_encryption_set_id     = azurerm_disk_encryption_set.test.id
  }

  service_principal {
    client_id     = azuread_application.test.application_id
    client_secret = azuread_service_principal_password.test.value
  }

  depends_on = [
    "azurerm_key_vault_access_policy.disk_encryption",
    "azurerm_role_assignment.role_network1",
    "azurerm_role_assignment.role_network2",
    "azurerm_role_assignment.disk_encryption_reader1",
    "azurerm_role_assignment.disk_encryption_reader2",
  ]
}
  