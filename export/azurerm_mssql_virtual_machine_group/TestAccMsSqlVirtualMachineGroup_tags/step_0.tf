
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-mssql-230825024940443987"
  location = "West Europe"
}

resource "azurerm_mssql_virtual_machine_group" "test" {
  name                = "acctestagc9buh"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  sql_image_offer = "SQL2017-WS2016"
  sql_image_sku   = "Developer"

  wsfc_domain_profile {
    fqdn                = "testdomain.com"
    cluster_subnet_type = "SingleSubnet"
  }

  tags = {
    test = "testing"
  }
}
