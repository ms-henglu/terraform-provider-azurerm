

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-storage-211013072437919740"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestvirtnet211013072437919740"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "test" {
  name                 = "acctestsubnet211013072437919740"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefix       = "10.0.2.0/24"
  service_endpoints    = ["Microsoft.Storage"]
}


resource "azurerm_storage_account" "synapse" {
  name                     = "acctestacc2v4o7"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_kind             = "BlobStorage"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_data_lake_gen2_filesystem" "test" {
  name               = "acctest-211013072437919740"
  storage_account_id = azurerm_storage_account.synapse.id
}

resource "azurerm_synapse_workspace" "test" {
  name                                 = "acctestsw211013072437919740"
  resource_group_name                  = azurerm_resource_group.test.name
  location                             = azurerm_resource_group.test.location
  storage_data_lake_gen2_filesystem_id = azurerm_storage_data_lake_gen2_filesystem.test.id
  sql_administrator_login              = "sqladminuser"
  sql_administrator_login_password     = "H@Sh1CoR3!"
}

resource "azurerm_storage_account" "test" {
  name                     = "unlikely23exst2acct2v4o7"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  network_rules {
    default_action = "Deny"
    ip_rules       = ["127.0.0.1"]
    private_link_access {
      endpoint_resource_id = azurerm_synapse_workspace.test.id
    }
  }

  tags = {
    environment = "production"
  }
}
