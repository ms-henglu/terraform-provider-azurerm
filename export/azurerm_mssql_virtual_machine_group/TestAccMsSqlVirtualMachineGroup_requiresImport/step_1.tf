

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-mssql-231020041508307394"
  location = "West Europe"
}

resource "azurerm_mssql_virtual_machine_group" "test" {
  name                = "acctestagl9c89"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  sql_image_offer = "SQL2017-WS2016"
  sql_image_sku   = "Developer"

  wsfc_domain_profile {
    fqdn                = "testdomain.com"
    cluster_subnet_type = "SingleSubnet"
  }
}

resource "azurerm_mssql_virtual_machine_group" "import" {
  name                = azurerm_mssql_virtual_machine_group.test.name
  resource_group_name = azurerm_mssql_virtual_machine_group.test.resource_group_name
  location            = azurerm_mssql_virtual_machine_group.test.location

  sql_image_offer = "SQL2017-WS2016"
  sql_image_sku   = "Developer"

  wsfc_domain_profile {
    fqdn                = "testdomain.com"
    cluster_subnet_type = "SingleSubnet"
  }
}
