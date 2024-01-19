
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "acctestRG-240119025218628803"
  location = "West Europe"
}

resource "azurerm_kusto_cluster" "cluster" {
  name                = "acctestkcs2lcr"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  sku {
    name     = "Dev(No SLA)_Standard_D11_v2"
    capacity = 1
  }
}

resource "azurerm_kusto_database" "test" {
  name                = "acctestkd-240119025218628803"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  cluster_name        = azurerm_kusto_cluster.cluster.name
  soft_delete_period  = "P31D"
  hot_cache_period    = "P7D"
}
