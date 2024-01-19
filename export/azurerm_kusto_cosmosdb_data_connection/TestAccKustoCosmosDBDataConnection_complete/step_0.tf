

provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119025218622867"
  location = "West Europe"
}

data "azurerm_role_definition" "builtin" {
  role_definition_id = "fbdf93bf-df7d-467e-a4d2-9458aa1360c8"
}

resource "azurerm_role_assignment" "test" {
  scope                = azurerm_resource_group.test.id
  role_definition_name = data.azurerm_role_definition.builtin.name
  principal_id         = azurerm_kusto_cluster.test.identity[0].principal_id
}

resource "azurerm_cosmosdb_account" "test" {
  name                = "acctest-ca-240119025218622867"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  consistency_policy {
    consistency_level       = "Session"
    max_interval_in_seconds = 5
    max_staleness_prefix    = 100
  }

  geo_location {
    location          = azurerm_resource_group.test.location
    failover_priority = 0
  }
}

resource "azurerm_cosmosdb_sql_database" "test" {
  name                = "acctestcosmosdbsqldb-240119025218622867"
  resource_group_name = azurerm_cosmosdb_account.test.resource_group_name
  account_name        = azurerm_cosmosdb_account.test.name
}

resource "azurerm_cosmosdb_sql_container" "test" {
  name                = "acctestcosmosdbsqlcon-240119025218622867"
  resource_group_name = azurerm_cosmosdb_account.test.resource_group_name
  account_name        = azurerm_cosmosdb_account.test.name
  database_name       = azurerm_cosmosdb_sql_database.test.name
  partition_key_path  = "/part"
  throughput          = 400
}

data "azurerm_cosmosdb_sql_role_definition" "test" {
  role_definition_id  = "00000000-0000-0000-0000-000000000001"
  resource_group_name = azurerm_resource_group.test.name
  account_name        = azurerm_cosmosdb_account.test.name
}


resource "azurerm_cosmosdb_sql_role_assignment" "test" {
  resource_group_name = azurerm_resource_group.test.name
  account_name        = azurerm_cosmosdb_account.test.name
  role_definition_id  = data.azurerm_cosmosdb_sql_role_definition.test.id
  principal_id        = azurerm_kusto_cluster.test.identity[0].principal_id
  scope               = azurerm_cosmosdb_account.test.id
}

resource "azurerm_kusto_cluster" "test" {
  name                = "acctestkco0jvp"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku {
    name     = "Dev(No SLA)_Standard_D11_v2"
    capacity = 1
  }

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_kusto_database" "test" {
  name                = "acctestkd-240119025218622867"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  cluster_name        = azurerm_kusto_cluster.test.name
}

resource "azurerm_kusto_script" "test" {
  name           = "create-table-script"
  database_id    = azurerm_kusto_database.test.id
  script_content = <<SCRIPT
.create table TestTable(Id:string, Name:string, _ts:long, _timestamp:datetime)
.create table TestTable ingestion json mapping "TestMapping"
'['
'    {"column":"Id","path":"$.id"},'
'    {"column":"Name","path":"$.name"},'
'    {"column":"_ts","path":"$._ts"},'
'    {"column":"_timestamp","path":"$._ts", "transform":"DateTimeFromUnixSeconds"}'
']'
.alter table TestTable policy ingestionbatching "{'MaximumBatchingTimeSpan': '0:0:10', 'MaximumNumberOfItems': 10000}"
SCRIPT
}


resource "azurerm_kusto_cosmosdb_data_connection" "test" {
  name                  = "acctestkcdo0jvp"
  location              = azurerm_resource_group.test.location
  cosmosdb_container_id = azurerm_cosmosdb_sql_container.test.id
  kusto_database_id     = azurerm_kusto_database.test.id
  managed_identity_id   = azurerm_kusto_cluster.test.id
  table_name            = "TestTable"
  mapping_rule_name     = "TestMapping"
  retrieval_start_date  = "2023-06-26T12:00:00.6554616Z"
}