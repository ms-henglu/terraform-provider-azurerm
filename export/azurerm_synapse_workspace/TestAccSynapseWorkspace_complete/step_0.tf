

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy       = false
      purge_soft_deleted_keys_on_destroy = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-synapse-240112225416432307"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestaccwok6t"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_kind             = "BlobStorage"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_data_lake_gen2_filesystem" "test" {
  name               = "acctest-240112225416432307"
  storage_account_id = azurerm_storage_account.test.id
}


data "azurerm_client_config" "current" {}


resource "azurerm_purview_account" "test" {
  name                = "acctestaccwok6t"
  resource_group_name = azurerm_resource_group.test.name
  location            = "West US 2"

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_virtual_network" "test" {
  name                = "wok6t-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "test" {
  name                 = "wok6t-subnet"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_synapse_workspace" "test" {
  name                                 = "acctestsw240112225416432307"
  resource_group_name                  = azurerm_resource_group.test.name
  location                             = azurerm_resource_group.test.location
  storage_data_lake_gen2_filesystem_id = azurerm_storage_data_lake_gen2_filesystem.test.id
  sql_administrator_login              = "sqladminuser"
  sql_administrator_login_password     = "H@Sh1CoR3!"
  data_exfiltration_protection_enabled = true
  managed_virtual_network_enabled      = true
  managed_resource_group_name          = "acctest-ManagedSynapse-240112225416432307"
  sql_identity_control_enabled         = true
  public_network_access_enabled        = false
  linking_allowed_for_aad_tenant_ids   = [data.azurerm_client_config.current.tenant_id]
  purview_id                           = azurerm_purview_account.test.id
  compute_subnet_id                    = azurerm_subnet.test.id

  identity {
    type = "SystemAssigned"
  }

  tags = {
    ENV = "Test"
  }
}
