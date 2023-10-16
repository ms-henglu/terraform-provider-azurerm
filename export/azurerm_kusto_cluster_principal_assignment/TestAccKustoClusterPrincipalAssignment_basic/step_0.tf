
provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "rg" {
  name     = "acctestRG-kusto-231016034116205866"
  location = "West Europe"
}

resource "azurerm_kusto_cluster" "test" {
  name                = "acctestkcxp03u"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  sku {
    name     = "Dev(No SLA)_Standard_D11_v2"
    capacity = 1
  }
}

resource "azurerm_kusto_cluster_principal_assignment" "test" {
  name                = "acctestkdpa231016034116205866"
  resource_group_name = azurerm_resource_group.rg.name
  cluster_name        = azurerm_kusto_cluster.test.name

  tenant_id      = data.azurerm_client_config.current.tenant_id
  principal_id   = data.azurerm_client_config.current.client_id
  principal_type = "App"
  role           = "AllDatabasesViewer"
}
