

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-cosmos-231016033649290471"
  location = "West Europe"
}

resource "azurerm_cosmosdb_account" "test" {
  name                = "acctest-cosmos-231016033649290471"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  consistency_policy {
    consistency_level = "Session"
  }

  geo_location {
    location          = azurerm_resource_group.test.location
    failover_priority = 0
  }
}

resource "azurerm_cosmosdb_sql_database" "test" {
  name                = "acctest-sql-database-231016033649290471"
  resource_group_name = azurerm_cosmosdb_account.test.resource_group_name
  account_name        = azurerm_cosmosdb_account.test.name
}

resource "azurerm_cosmosdb_sql_container" "test" {
  name                = "acctest-sql-container-231016033649290471"
  resource_group_name = azurerm_cosmosdb_account.test.resource_group_name
  account_name        = azurerm_cosmosdb_account.test.name
  database_name       = azurerm_cosmosdb_sql_database.test.name
  partition_key_path  = "/definition/id"
}
	

resource "azurerm_cosmosdb_sql_function" "test" {
  name         = "acctest-dssdf-231016033649290471"
  container_id = azurerm_cosmosdb_sql_container.test.id
  body         = <<BODY
  	function test() {
		var context = getContext();
		var response = context.getResponse();
		response.setBody('Hello, World');
	}
BODY
}
