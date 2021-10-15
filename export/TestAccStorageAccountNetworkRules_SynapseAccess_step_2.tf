


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-storage-211015014900655727"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestvirtnet211015014900655727"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "test" {
  name                 = "acctestsubnet211015014900655727"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefix       = "10.0.2.0/24"
  service_endpoints    = ["Microsoft.Storage"]
}


resource "azurerm_subnet" "blob_endpoint" {
  name                 = "acctestsnetblobendpoint-211015014900655727"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.5.0/24"]

  enforce_private_link_endpoint_network_policies = true
}

resource "azurerm_subnet" "table_endpoint" {
  name                 = "acctestsnettableendpoint-211015014900655727"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.6.0/24"]

  enforce_private_link_endpoint_network_policies = true
}

resource "azurerm_storage_account" "blob_connection" {
  name                     = "accblobconnacct0mxoj"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_account" "table_connection" {
  name                     = "acctableconnacct0mxoj"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_private_dns_zone" "blob" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_private_dns_zone" "table" {
  name                = "privatelink.table.core.windows.net"
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_private_endpoint" "blob" {
  name                = "acctest-privatelink-blob-211015014900655727"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  subnet_id           = azurerm_subnet.blob_endpoint.id

  private_service_connection {
    name                           = "acctest-privatelink-mssc-211015014900655727"
    private_connection_resource_id = azurerm_storage_account.blob_connection.id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }
}

resource "azurerm_private_endpoint" "table" {
  name                = "acctest-privatelink-table-211015014900655727"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  subnet_id           = azurerm_subnet.table_endpoint.id

  private_service_connection {
    name                           = "acctest-privatelink-mssc-211015014900655727"
    private_connection_resource_id = azurerm_storage_account.table_connection.id
    subresource_names              = ["table"]
    is_manual_connection           = false
  }
}


resource "azurerm_storage_account" "synapse" {
  name                     = "acctestacc0mxoj"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_kind             = "BlobStorage"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_data_lake_gen2_filesystem" "test" {
  name               = "acctest-211015014900655727"
  storage_account_id = azurerm_storage_account.synapse.id
}

resource "azurerm_synapse_workspace" "test" {
  name                                 = "acctestsw211015014900655727"
  resource_group_name                  = azurerm_resource_group.test.name
  location                             = azurerm_resource_group.test.location
  storage_data_lake_gen2_filesystem_id = azurerm_storage_data_lake_gen2_filesystem.test.id
  sql_administrator_login              = "sqladminuser"
  sql_administrator_login_password     = "H@Sh1CoR3!"
}


resource "azurerm_storage_account" "test" {
  name                     = "unlikely23exst2acct0mxoj"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "production"
  }
}

resource "azurerm_storage_account_network_rules" "test" {
  resource_group_name  = azurerm_resource_group.test.name
  storage_account_name = azurerm_storage_account.test.name

  default_action = "Deny"
  ip_rules       = ["127.0.0.1"]
  private_link_access {
    endpoint_resource_id = azurerm_synapse_workspace.test.id
  }
}
