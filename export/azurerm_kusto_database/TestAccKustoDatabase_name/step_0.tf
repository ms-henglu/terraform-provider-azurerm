
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "acctestRG-240119025218623630"
  location = "West Europe"
}

resource "azurerm_kusto_cluster" "cluster" {
  name                = "acctestkcgv4ue"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  sku {
    name     = "Dev(No SLA)_Standard_D11_v2"
    capacity = 1
  }
}

resource "azurerm_kusto_database" "test" {
  name                = "acctest_kd_240119025218623630"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  cluster_name        = azurerm_kusto_cluster.cluster.name
}
