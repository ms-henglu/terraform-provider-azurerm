
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-databricks-230414021124590143"
  location = "West Europe"
}


resource "azurerm_databricks_access_connector" "test" {
  name                = "acctestDBAC230414021124590143"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
