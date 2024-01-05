

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240105064642286052"
  location = "West Europe"
}

resource "azurerm_sql_server" "test" {
  name                         = "acctest240105064642286052"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  version                      = "12.0"
  administrator_login          = "4dm1n157r470r"
  administrator_login_password = "4-v3ry-53cr37-p455w0rd"
}

resource "azurerm_sql_elasticpool" "test" {
  name                = "acctest-pool-240105064642286052"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  server_name         = azurerm_sql_server.test.name
  edition             = "Basic"
  dtu                 = 50
  pool_size           = 5000
}


resource "azurerm_sql_elasticpool" "import" {
  name                = azurerm_sql_elasticpool.test.name
  resource_group_name = azurerm_sql_elasticpool.test.resource_group_name
  location            = azurerm_sql_elasticpool.test.location
  server_name         = azurerm_sql_elasticpool.test.server_name
  edition             = azurerm_sql_elasticpool.test.edition
  dtu                 = azurerm_sql_elasticpool.test.dtu
  pool_size           = azurerm_sql_elasticpool.test.pool_size
}
