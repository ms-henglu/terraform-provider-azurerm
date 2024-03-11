

provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-databricks-240311031813481228"
  location = "West Europe"
}


resource "azurerm_databricks_access_connector" "test" {
  name                = "acctestDBAC240311031813481228"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}


resource "azurerm_databricks_access_connector" "import" {
  name                = azurerm_databricks_access_connector.test.name
  resource_group_name = azurerm_databricks_access_connector.test.resource_group_name
  location            = azurerm_databricks_access_connector.test.location
}
