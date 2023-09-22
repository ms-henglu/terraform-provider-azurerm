


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-230922054015295204"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf230922054015295204"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_kusto_cluster" "test" {
  name                = "acctestkc1fo0z"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  sku {
    name     = "Dev(No SLA)_Standard_D11_v2"
    capacity = 1
  }
}

resource "azurerm_kusto_database" "test" {
  name                = "acctestkd-230922054015295204"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  cluster_name        = azurerm_kusto_cluster.test.name
}


resource "azurerm_data_factory_linked_service_kusto" "test" {
  name                 = "acctestlskusto230922054015295204"
  data_factory_id      = azurerm_data_factory.test.id
  kusto_endpoint       = azurerm_kusto_cluster.test.uri
  kusto_database_name  = azurerm_kusto_database.test.name
  use_managed_identity = true
}


resource "azurerm_data_factory_linked_service_kusto" "import" {
  name                 = azurerm_data_factory_linked_service_kusto.test.name
  data_factory_id      = azurerm_data_factory_linked_service_kusto.test.data_factory_id
  kusto_endpoint       = azurerm_data_factory_linked_service_kusto.test.kusto_endpoint
  kusto_database_name  = azurerm_data_factory_linked_service_kusto.test.kusto_database_name
  use_managed_identity = azurerm_data_factory_linked_service_kusto.test.use_managed_identity
}
