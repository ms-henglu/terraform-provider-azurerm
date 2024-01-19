
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-psql-240119025622789913"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctest-VNET-240119025622789913"
  address_space       = ["10.7.29.0/29"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "test" {
  name                 = "acctest-SN-240119025622789913"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.7.29.0/29"]
  service_endpoints    = ["Microsoft.Sql"]
}

resource "azurerm_postgresql_server" "test" {
  name                         = "acctest-psql-server-240119025622789913"
  location                     = azurerm_resource_group.test.location
  resource_group_name          = azurerm_resource_group.test.name
  administrator_login          = "acctestun"
  administrator_login_password = "H@Sh1CoR3!"
  version                      = "9.5"
  ssl_enforcement_enabled      = true

  sku_name = "GP_Gen5_2"

  storage_mb                   = 51200
  backup_retention_days        = 7
  geo_redundant_backup_enabled = false
}

resource "azurerm_postgresql_virtual_network_rule" "test" {
  name                = "acctest-PSQL-VNET-rule-240119025622789913"
  resource_group_name = azurerm_resource_group.test.name
  server_name         = azurerm_postgresql_server.test.name
  subnet_id           = azurerm_subnet.test.id
}
