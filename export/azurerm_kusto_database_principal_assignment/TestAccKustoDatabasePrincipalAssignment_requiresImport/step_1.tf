

provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "rg" {
  name     = "acctestRG-kusto-240105060950675007"
  location = "West Europe"
}

resource "azurerm_kusto_cluster" "test" {
  name                = "acctestkccslti"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  sku {
    name     = "Dev(No SLA)_Standard_D11_v2"
    capacity = 1
  }
}

resource "azurerm_kusto_database" "test" {
  name                = "acctestkd-240105060950675007"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  cluster_name        = azurerm_kusto_cluster.test.name
}

resource "azurerm_kusto_database_principal_assignment" "test" {
  name                = "acctestkdpa240105060950675007"
  resource_group_name = azurerm_resource_group.rg.name
  cluster_name        = azurerm_kusto_cluster.test.name
  database_name       = azurerm_kusto_database.test.name

  tenant_id      = data.azurerm_client_config.current.tenant_id
  principal_id   = data.azurerm_client_config.current.client_id
  principal_type = "App"
  role           = "Viewer"
}


resource "azurerm_kusto_database_principal_assignment" "import" {
  name                = azurerm_kusto_database_principal_assignment.test.name
  resource_group_name = azurerm_kusto_database_principal_assignment.test.resource_group_name
  cluster_name        = azurerm_kusto_database_principal_assignment.test.cluster_name
  database_name       = azurerm_kusto_database_principal_assignment.test.database_name

  tenant_id      = azurerm_kusto_database_principal_assignment.test.tenant_id
  principal_id   = azurerm_kusto_database_principal_assignment.test.principal_id
  principal_type = azurerm_kusto_database_principal_assignment.test.principal_type
  role           = azurerm_kusto_database_principal_assignment.test.role
}
