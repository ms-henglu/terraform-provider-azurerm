

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-digitaltwin-240112224404779250"
  location = "West Europe"
}

resource "azurerm_digital_twins_instance" "test" {
  name                = "acctest-DT-240112224404779250"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_eventhub_namespace" "test" {
  name                = "acctesteventhubnamespace-240112224404779250"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"
}

resource "azurerm_eventhub" "test" {
  name                = "acctesteventhub-240112224404779250"
  namespace_name      = azurerm_eventhub_namespace.test.name
  resource_group_name = azurerm_resource_group.test.name
  partition_count     = 2
  message_retention   = 7
}

resource "azurerm_kusto_cluster" "test" {
  name                = "acctestkc3hg2i"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  sku {
    name     = "Dev(No SLA)_Standard_D11_v2"
    capacity = 1
  }
}

resource "azurerm_kusto_database" "test" {
  name                = "acctestkd-240112224404779250"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  cluster_name        = azurerm_kusto_cluster.test.name
}

resource "azurerm_role_assignment" "database_contributor" {
  scope                = azurerm_kusto_database.test.id
  principal_id         = azurerm_digital_twins_instance.test.identity.0.principal_id
  role_definition_name = "Contributor"
}

resource "azurerm_role_assignment" "eventhub_data_owner" {
  scope                = azurerm_eventhub.test.id
  principal_id         = azurerm_digital_twins_instance.test.identity.0.principal_id
  role_definition_name = "Azure Event Hubs Data Owner"
}

resource "azurerm_kusto_database_principal_assignment" "test" {
  name                = "acctestkdpa240112224404779250"
  resource_group_name = azurerm_resource_group.test.name
  cluster_name        = azurerm_kusto_cluster.test.name
  database_name       = azurerm_kusto_database.test.name

  tenant_id      = azurerm_digital_twins_instance.test.identity.0.tenant_id
  principal_id   = azurerm_digital_twins_instance.test.identity.0.principal_id
  principal_type = "App"
  role           = "Admin"
}



resource "azurerm_eventhub_consumer_group" "test" {
  name                = "acctesteventhubcg-240112224404779250"
  namespace_name      = azurerm_eventhub_namespace.test.name
  eventhub_name       = azurerm_eventhub.test.name
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_digital_twins_time_series_database_connection" "test" {
  name                            = "connection-240112224404779250"
  digital_twins_id                = azurerm_digital_twins_instance.test.id
  eventhub_name                   = azurerm_eventhub.test.name
  eventhub_namespace_id           = azurerm_eventhub_namespace.test.id
  eventhub_namespace_endpoint_uri = "sb://${azurerm_eventhub_namespace.test.name}.servicebus.windows.net"
  kusto_cluster_id                = azurerm_kusto_cluster.test.id
  kusto_cluster_uri               = azurerm_kusto_cluster.test.uri
  kusto_database_name             = azurerm_kusto_database.test.name

  eventhub_consumer_group_name = azurerm_eventhub_consumer_group.test.name
  kusto_table_name             = "mytable"

  depends_on = [
    azurerm_role_assignment.database_contributor,
    azurerm_role_assignment.eventhub_data_owner,
    azurerm_kusto_database_principal_assignment.test
  ]
}
