

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-ca-230922053906109563"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctvn-230922053906109563"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "test" {
  name                 = "acctsub-230922053906109563"
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
  name                           = "acctca-mi-cluster-230922053906109563"
  resource_group_name            = azurerm_resource_group.test.name
  location                       = azurerm_resource_group.test.location
  delegated_management_subnet_id = azurerm_subnet.test.id
  default_admin_password         = "Password1234"
  authentication_method          = "Cassandra"
  version                        = "3.11"
  repair_enabled                 = true

  client_certificate_pems          = [file("testdata/cert.pem")]
  external_gossip_certificate_pems = [file("testdata/cert.pem")]
  external_seed_node_ip_addresses  = ["10.52.221.2"]
  hours_between_backups            = 22

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Env = "Test1"
  }

  depends_on = [azurerm_role_assignment.test]
}
