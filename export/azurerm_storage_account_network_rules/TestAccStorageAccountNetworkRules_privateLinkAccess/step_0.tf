


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-storage-231013044344473152"
  location = "westeurope"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestvirtnet231013044344473152"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "test" {
  name                 = "acctestsubnet231013044344473152"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.2.0/24"]
  service_endpoints    = ["Microsoft.Storage"]
}


resource "azurerm_subnet" "blob_endpoint" {
  name                 = "acctestsnetblobendpoint-231013044344473152"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.5.0/24"]

  enforce_private_link_endpoint_network_policies = true
}

resource "azurerm_subnet" "table_endpoint" {
  name                 = "acctestsnettableendpoint-231013044344473152"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.6.0/24"]

  enforce_private_link_endpoint_network_policies = true
}

resource "azurerm_storage_account" "blob_connection" {
  name                     = "accblobconnacctyw60q"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_account" "table_connection" {
  name                     = "acctableconnacctyw60q"
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
  name                = "acctest-privatelink-blob-231013044344473152"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  subnet_id           = azurerm_subnet.blob_endpoint.id

  private_service_connection {
    name                           = "acctest-privatelink-mssc-231013044344473152"
    private_connection_resource_id = azurerm_storage_account.blob_connection.id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }
}

resource "azurerm_private_endpoint" "table" {
  name                = "acctest-privatelink-table-231013044344473152"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  subnet_id           = azurerm_subnet.table_endpoint.id

  private_service_connection {
    name                           = "acctest-privatelink-mssc-231013044344473152"
    private_connection_resource_id = azurerm_storage_account.table_connection.id
    subresource_names              = ["table"]
    is_manual_connection           = false
  }
}


resource "azurerm_storage_account" "test" {
  name                     = "unlikely23exst2acctyw60q"
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

  default_action             = "Deny"
  bypass                     = ["None"]
  ip_rules                   = []
  virtual_network_subnet_ids = []
}
