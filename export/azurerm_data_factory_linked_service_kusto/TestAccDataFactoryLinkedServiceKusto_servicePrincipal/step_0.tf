

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-230721011523154636"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf230721011523154636"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_kusto_cluster" "test" {
  name                = "acctestkcxuglw"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  sku {
    name     = "Dev(No SLA)_Standard_D11_v2"
    capacity = 1
  }
}

resource "azurerm_kusto_database" "test" {
  name                = "acctestkd-230721011523154636"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  cluster_name        = azurerm_kusto_cluster.test.name
}


data "azurerm_client_config" "current" {
}

resource "azurerm_data_factory_linked_service_kusto" "test" {
  name                  = "acctestlskusto230721011523154636"
  data_factory_id       = azurerm_data_factory.test.id
  kusto_endpoint        = azurerm_kusto_cluster.test.uri
  kusto_database_name   = azurerm_kusto_database.test.name
  service_principal_id  = data.azurerm_client_config.current.client_id
  service_principal_key = "testkey"
  tenant                = data.azurerm_client_config.current.tenant_id
}
