


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-ca-230804025710156223"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctvn-230804025710156223"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "test" {
  name                 = "acctsub-230804025710156223"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.1.0/24"]
}

data "azuread_service_principal" "test" {
  display_name = "Azure Cosmos DB"
}

resource "azurerm_role_assignment" "test" {
  scope                = azurerm_virtual_network.test.id
  role_definition_name = "Network Contributor"
  principal_id         = data.azuread_service_principal.test.object_id
}


resource "azurerm_cosmosdb_cassandra_cluster" "test" {
  name                           = "acctca-mi-cluster-230804025710156223"
  resource_group_name            = azurerm_resource_group.test.name
  location                       = azurerm_resource_group.test.location
  delegated_management_subnet_id = azurerm_subnet.test.id
  default_admin_password         = "Password1234"

  depends_on = [azurerm_role_assignment.test]
}


resource "azurerm_cosmosdb_cassandra_cluster" "import" {
  name                           = azurerm_cosmosdb_cassandra_cluster.test.name
  resource_group_name            = azurerm_cosmosdb_cassandra_cluster.test.resource_group_name
  location                       = azurerm_cosmosdb_cassandra_cluster.test.location
  delegated_management_subnet_id = azurerm_subnet.test.id
  default_admin_password         = "Password1234"
}
