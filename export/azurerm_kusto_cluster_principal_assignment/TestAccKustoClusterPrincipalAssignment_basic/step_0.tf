
provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "rg" {
  name     = "acctestRG-kusto-230929065101261518"
  location = "West Europe"
}

resource "azurerm_kusto_cluster" "test" {
  name                = "acctestkcmdxtn"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  sku {
    name     = "Dev(No SLA)_Standard_D11_v2"
    capacity = 1
  }
}

resource "azurerm_kusto_cluster_principal_assignment" "test" {
  name                = "acctestkdpa230929065101261518"
  resource_group_name = azurerm_resource_group.rg.name
  cluster_name        = azurerm_kusto_cluster.test.name

  tenant_id      = data.azurerm_client_config.current.tenant_id
  principal_id   = data.azurerm_client_config.current.client_id
  principal_type = "App"
  role           = "AllDatabasesViewer"
}
