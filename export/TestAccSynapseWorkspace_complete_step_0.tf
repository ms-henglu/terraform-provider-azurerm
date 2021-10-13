

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-synapse-211013072500252211"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestaccujtt8"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_kind             = "BlobStorage"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_data_lake_gen2_filesystem" "test" {
  name               = "acctest-211013072500252211"
  storage_account_id = azurerm_storage_account.test.id
}


resource "azurerm_synapse_workspace" "test" {
  name                                 = "acctestsw211013072500252211"
  resource_group_name                  = azurerm_resource_group.test.name
  location                             = azurerm_resource_group.test.location
  storage_data_lake_gen2_filesystem_id = azurerm_storage_data_lake_gen2_filesystem.test.id
  sql_administrator_login              = "sqladminuser"
  sql_administrator_login_password     = "H@Sh1CoR3!"
  data_exfiltration_protection_enabled = true
  managed_virtual_network_enabled      = true
  managed_resource_group_name          = "acctest-ManagedSynapse-211013072500252211"
  sql_identity_control_enabled         = true

  tags = {
    ENV = "Test"
  }
}
