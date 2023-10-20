
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "acctestRG-231020041250870986"
  location = "West Europe"
}

resource "azurerm_kusto_cluster" "cluster1" {
  name                = "acctestkc1antg8"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  sku {
    name     = "Dev(No SLA)_Standard_D11_v2"
    capacity = 1
  }
}

resource "azurerm_kusto_cluster" "cluster2" {
  name                = "acctestkc2antg8"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  sku {
    name     = "Dev(No SLA)_Standard_D11_v2"
    capacity = 1
  }
}

resource "azurerm_kusto_database" "followed_database" {
  name                = "acctestkd-231020041250870986"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  cluster_name        = azurerm_kusto_cluster.cluster1.name
}

resource "azurerm_kusto_database" "test" {
  name                = "acctestkd2-231020041250870986"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  cluster_name        = azurerm_kusto_cluster.cluster2.name
}

resource "azurerm_kusto_attached_database_configuration" "test" {
  name                = "acctestka-231020041250870986"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  cluster_name        = azurerm_kusto_cluster.cluster1.name
  cluster_resource_id = azurerm_kusto_cluster.cluster2.id
  database_name       = azurerm_kusto_database.test.name

  sharing {
    external_tables_to_exclude    = ["ExternalTable2"]
    external_tables_to_include    = ["ExternalTable1"]
    materialized_views_to_exclude = ["MaterializedViewTable2"]
    materialized_views_to_include = ["MaterializedViewTable1"]
    tables_to_exclude             = ["Table2"]
    tables_to_include             = ["Table1"]
  }
}
