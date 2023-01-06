

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-230106034355704488"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf230106034355704488"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_kusto_cluster" "test" {
  name                = "acctestkc79sg7"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  sku {
    name     = "Dev(No SLA)_Standard_D11_v2"
    capacity = 1
  }
}

resource "azurerm_kusto_database" "test" {
  name                = "acctestkd-230106034355704488"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  cluster_name        = azurerm_kusto_cluster.test.name
}


resource "azurerm_data_factory_linked_service_kusto" "test" {
  name                 = "acctestlskusto230106034355704488"
  data_factory_id      = azurerm_data_factory.test.id
  kusto_endpoint       = azurerm_kusto_cluster.test.uri
  kusto_database_name  = azurerm_kusto_database.test.name
  use_managed_identity = true
}
