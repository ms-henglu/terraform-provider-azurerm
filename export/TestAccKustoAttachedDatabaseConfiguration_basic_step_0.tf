
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "acctestRG-210830084118696974"
  location = "West Europe"
}

resource "azurerm_kusto_cluster" "cluster1" {
  name                = "acctestkc1n9ddy"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  sku {
    name     = "Dev(No SLA)_Standard_D11_v2"
    capacity = 1
  }
}

resource "azurerm_kusto_cluster" "cluster2" {
  name                = "acctestkc2n9ddy"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  sku {
    name     = "Dev(No SLA)_Standard_D11_v2"
    capacity = 1
  }
}

resource "azurerm_kusto_database" "followed_database" {
  name                = "acctestkd-210830084118696974"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  cluster_name        = azurerm_kusto_cluster.cluster1.name
}

resource "azurerm_kusto_attached_database_configuration" "test" {
  name                = "acctestka-210830084118696974"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  cluster_name        = azurerm_kusto_cluster.cluster1.name
  cluster_resource_id = azurerm_kusto_cluster.cluster2.id
  database_name       = "*"
}
