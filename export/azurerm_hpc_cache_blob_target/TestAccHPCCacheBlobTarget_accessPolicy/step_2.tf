


provider "azurerm" {
  features {}
}

provider "azuread" {}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-storage-231013043552597952"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctest-VN-231013043552597952"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "test" {
  name                 = "acctestsub-231013043552597952"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.2.0/24"]
}

data "azuread_service_principal" "test" {
  display_name = "HPC Cache Resource Provider"
}

resource "azurerm_storage_account" "test" {
  name                     = "accteststorgaccmpd77"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                 = "acctest-strgctn-mpd77"
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
  name                = "acctest-HPCC-231013043552597952"
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
  name         = "p1"
  hpc_cache_id = azurerm_hpc_cache.test.id
  access_rule {
    scope  = "default"
    access = "rw"
  }

  # This is not needed in Terraform v0.13, whilst needed in v0.14.
  # Once https://github.com/hashicorp/terraform/issues/28193 is fixed, we can remove this lifecycle block.
  lifecycle {
    create_before_destroy = true
  }
}

resource "azurerm_hpc_cache_blob_target" "test" {
  name                 = "acctest-HPCCTGT-mpd77"
  resource_group_name  = azurerm_resource_group.test.name
  cache_name           = azurerm_hpc_cache.test.name
  storage_container_id = azurerm_storage_container.test.resource_manager_id
  namespace_path       = "/blob_storage1"
  access_policy_name   = azurerm_hpc_cache_access_policy.test.name
}
