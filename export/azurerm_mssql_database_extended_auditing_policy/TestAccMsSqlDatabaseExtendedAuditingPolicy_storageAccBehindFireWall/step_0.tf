
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-mssql-230825024940415009"
  location = "West Europe"
}

resource "azurerm_mssql_server" "test" {
  name                         = "acctest-sqlserver-230825024940415009"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  version                      = "12.0"
  administrator_login          = "missadministrator"
  administrator_login_password = "AdminPassword123!"
  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_mssql_database" "test" {
  name      = "acctest-db-230825024940415009"
  server_id = azurerm_mssql_server.test.id
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestvirtnet230825024940415009"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "test" {
  name                                           = "acctestsubnet230825024940415009"
  resource_group_name                            = azurerm_resource_group.test.name
  virtual_network_name                           = azurerm_virtual_network.test.name
  address_prefixes                               = ["10.0.2.0/24"]
  service_endpoints                              = ["Microsoft.Storage", "Microsoft.Sql"]
  enforce_private_link_endpoint_network_policies = true
}

resource "azurerm_storage_account" "test" {
  name                     = "unlikely23exst2acctc0s4y"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  network_rules {
    default_action             = "Deny"
    ip_rules                   = ["127.0.0.1"]
    virtual_network_subnet_ids = [azurerm_subnet.test.id]
    bypass                     = ["AzureServices"]
  }

  identity {
    type = "SystemAssigned"

  }
}

resource "azurerm_mssql_virtual_network_rule" "sqlvnetrule" {
  name      = "sql-vnet-rule"
  server_id = azurerm_mssql_server.test.id
  subnet_id = azurerm_subnet.test.id

}

resource "azurerm_mssql_firewall_rule" "test" {
  name             = "FirewallRule1"
  server_id        = azurerm_mssql_server.test.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}


resource "azurerm_mssql_database_extended_auditing_policy" "test" {
  database_id      = azurerm_mssql_database.test.id
  storage_endpoint = azurerm_storage_account.test.primary_blob_endpoint

  depends_on = [
    azurerm_role_assignment.test,
  ]
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_role_assignment" "test" {
  scope                = data.azurerm_subscription.primary.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_mssql_server.test.identity.0.principal_id
}

resource "azurerm_mssql_server_extended_auditing_policy" "test" {
  storage_endpoint       = azurerm_storage_account.test.primary_blob_endpoint
  server_id              = azurerm_mssql_server.test.id
  retention_in_days      = 6
  log_monitoring_enabled = false

  storage_account_subscription_id = "ARM_SUBSCRIPTION_ID"

  depends_on = [
    azurerm_role_assignment.test,
    azurerm_storage_account.test,
  ]
}


