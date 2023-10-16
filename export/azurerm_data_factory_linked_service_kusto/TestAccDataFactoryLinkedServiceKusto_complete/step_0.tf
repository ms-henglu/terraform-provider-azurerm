

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-231016033759698517"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf231016033759698517"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_kusto_cluster" "test" {
  name                = "acctestkcmcqmf"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  sku {
    name     = "Dev(No SLA)_Standard_D11_v2"
    capacity = 1
  }
}

resource "azurerm_kusto_database" "test" {
  name                = "acctestkd-231016033759698517"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  cluster_name        = azurerm_kusto_cluster.test.name
}


resource "azurerm_data_factory_linked_service_kusto" "test" {
  name                 = "acctestlskusto231016033759698517"
  data_factory_id      = azurerm_data_factory.test.id
  kusto_endpoint       = azurerm_kusto_cluster.test.uri
  kusto_database_name  = azurerm_kusto_database.test.name
  use_managed_identity = true

  annotations = ["test1", "test2", "test3"]
  description = "test description"

  parameters = {
    foo = "test1"
    bar = "test2"
  }

  additional_properties = {
    foo = "test1"
    bar = "test2"
  }
}
