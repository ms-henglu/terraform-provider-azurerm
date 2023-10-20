


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-storage-231020041948022197"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestvirtnet231020041948022197"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "test" {
  name                 = "acctestsubnet231020041948022197"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.2.0/24"]
  service_endpoints    = ["Microsoft.Storage"]
}


resource "azurerm_subnet" "blob_endpoint" {
  name                 = "acctestsnetblobendpoint-231020041948022197"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.5.0/24"]

  enforce_private_link_endpoint_network_policies = true
}

resource "azurerm_subnet" "table_endpoint" {
  name                 = "acctestsnettableendpoint-231020041948022197"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.6.0/24"]

  enforce_private_link_endpoint_network_policies = true
}

resource "azurerm_storage_account" "blob_connection" {
  name                     = "accblobconnaccte81yf"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_account" "table_connection" {
  name                     = "acctableconnaccte81yf"
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
  name                = "acctest-privatelink-blob-231020041948022197"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  subnet_id           = azurerm_subnet.blob_endpoint.id

  private_service_connection {
    name                           = "acctest-privatelink-mssc-231020041948022197"
    private_connection_resource_id = azurerm_storage_account.blob_connection.id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }
}

resource "azurerm_private_endpoint" "table" {
  name                = "acctest-privatelink-table-231020041948022197"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  subnet_id           = azurerm_subnet.table_endpoint.id

  private_service_connection {
    name                           = "acctest-privatelink-mssc-231020041948022197"
    private_connection_resource_id = azurerm_storage_account.table_connection.id
    subresource_names              = ["table"]
    is_manual_connection           = false
  }
}


resource "azurerm_storage_account" "synapse" {
  name                     = "acctestacce81yf"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_kind             = "BlobStorage"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_data_lake_gen2_filesystem" "test" {
  name               = "acctest-231020041948022197"
  storage_account_id = azurerm_storage_account.synapse.id
}

resource "azurerm_synapse_workspace" "test" {
  name                                 = "acctestsw231020041948022197"
  resource_group_name                  = azurerm_resource_group.test.name
  location                             = azurerm_resource_group.test.location
  storage_data_lake_gen2_filesystem_id = azurerm_storage_data_lake_gen2_filesystem.test.id
  sql_administrator_login              = "sqladminuser"
  sql_administrator_login_password     = "H@Sh1CoR3!"

  identity {
    type = "SystemAssigned"
  }
}


resource "azurerm_storage_account" "test" {
  name                     = "unlikely23exst2accte81yf"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "production"
  }
}

resource "azurerm_storage_account_network_rules" "test" {
  storage_account_id = azurerm_storage_account.test.id

  default_action = "Deny"
  ip_rules       = ["127.0.0.1"]
  private_link_access {
    endpoint_resource_id = azurerm_synapse_workspace.test.id
  }
}
