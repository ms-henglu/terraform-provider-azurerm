


provider "azurerm" {
  features {}
}

provider "azuread" {}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-storage-211112020717350359"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctest-VN-211112020717350359"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "test" {
  name                 = "acctestsub-211112020717350359"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefix       = "10.0.2.0/24"
}

data "azuread_service_principal" "test" {
  display_name = "HPC Cache Resource Provider"
}

resource "azurerm_storage_account" "test" {
  name                     = "accteststorgacc68rhf"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                 = "acctest-strgctn-68rhf"
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
  name                = "acctest-HPCC-211112020717350359"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  cache_size_in_gb    = 3072
  subnet_id           = azurerm_subnet.test.id
  sku_name            = "Standard_2G"
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
  name                 = "acctest-HPCCTGT-68rhf"
  resource_group_name  = azurerm_resource_group.test.name
  cache_name           = azurerm_hpc_cache.test.name
  storage_container_id = azurerm_storage_container.test.resource_manager_id
  namespace_path       = "/blob_storage1"
  access_policy_name   = azurerm_hpc_cache_access_policy.test.name
}
