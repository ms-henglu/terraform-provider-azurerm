


provider "azurerm" {
  features {}
}

provider "azuread" {}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-storage-240105064718289815"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctest-VN-240105064718289815"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "test" {
  name                 = "acctestsub-240105064718289815"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.2.0/24"]
}

data "azuread_service_principal" "test" {
  display_name = "HPC Cache Resource Provider"
}

resource "azurerm_storage_account" "test" {
  name                     = "accteststorgacczotjl"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                 = "acctest-strgctn-zotjl"
  storage_account_name = azurerm_storage_account.test.name
}

resource "azurerm_role_assignment" "test_storage_account_contrib" {
  scope                = azurerm_storage_account.test.id
  role_definition_name = "Storage Account Contributor"
  principal_id         = data.azuread_service_principal.test.object_id
}

resource "azurerm_role_assignment" "test_storage_blob_data_contrib" {
  scope                = azurerm_storage_account.test.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = data.azuread_service_principal.test.object_id
}


resource "azurerm_hpc_cache" "test" {
  name                = "acctest-HPCC-240105064718289815"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  cache_size_in_gb    = 3072
  subnet_id           = azurerm_subnet.test.id
  sku_name            = "Standard_2G"

  # hpc_cache_blob_target depends on below role_assignments, however these role_assignments need up to 5 minutes to take effect.
  # Since hpc_cache_blob_target depends on the hpc_cache and hpc_cache takes far more than 5 minutes to create, put the dependency here so role_assignments are ready before creating hpc_cache_blob_target.
  depends_on = [
    azurerm_role_assignment.test_storage_account_contrib,
    azurerm_role_assignment.test_storage_blob_data_contrib,
  ]
}


resource "azurerm_hpc_cache_access_policy" "test" {
  name         = "p2"
  hpc_cache_id = azurerm_hpc_cache.test.id
  access_rule {
    scope  = "default"
    access = "rw"
  }
  # This is necessary to make the Terraform apply order works correctly.
  # Without CBD: azurerm_hpc_cache_access_policy-p1 (destroy) -> azurerm_hpc_cache_blob_target (update) -> azurerm_hpc_cache_access_policy-p2 (create)
  # 			 (the 1st step wil fail as the access policy is under used by the blob target)
  # With CBD   : azurerm_hpc_cache_access_policy-p2 (create) -> azurerm_hpc_cache_blob_target (update) -> azurerm_hpc_cache_access_policy-p1 (delete)
  lifecycle {
    create_before_destroy = true
  }
}

resource "azurerm_hpc_cache_blob_target" "test" {
  name                 = "acctest-HPCCTGT-zotjl"
  resource_group_name  = azurerm_resource_group.test.name
  cache_name           = azurerm_hpc_cache.test.name
  storage_container_id = azurerm_storage_container.test.resource_manager_id
  namespace_path       = "/blob_storage1"
  access_policy_name   = azurerm_hpc_cache_access_policy.test.name
}
