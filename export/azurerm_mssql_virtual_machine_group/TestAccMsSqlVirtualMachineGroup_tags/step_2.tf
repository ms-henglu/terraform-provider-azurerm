
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-mssql-231016034338833861"
  location = "West Europe"
}

resource "azurerm_mssql_virtual_machine_group" "test" {
  name                = "acctestag2fzcf"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  sql_image_offer = "SQL2017-WS2016"
  sql_image_sku   = "Developer"

  wsfc_domain_profile {
    fqdn                = "testdomain.com"
    cluster_subnet_type = "SingleSubnet"
  }

  tags = {
    test = "testing2"
  }
}
