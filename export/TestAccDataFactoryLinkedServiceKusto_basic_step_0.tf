

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-220623223303904876"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf220623223303904876"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_kusto_cluster" "test" {
  name                = "acctestkc794lw"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  sku {
    name     = "Dev(No SLA)_Standard_D11_v2"
    capacity = 1
  }
}

resource "azurerm_kusto_database" "test" {
  name                = "acctestkd-220623223303904876"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  cluster_name        = azurerm_kusto_cluster.test.name
}


resource "azurerm_data_factory_linked_service_kusto" "test" {
  name                 = "acctestlskusto220623223303904876"
  data_factory_id      = azurerm_data_factory.test.id
  kusto_endpoint       = azurerm_kusto_cluster.test.uri
  kusto_database_name  = azurerm_kusto_database.test.name
  use_managed_identity = true
}
