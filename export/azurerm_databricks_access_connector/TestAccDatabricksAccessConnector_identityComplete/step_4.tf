
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-databricks-240112034207943198"
  location = "West Europe"
}


resource "azurerm_databricks_access_connector" "test" {
  name                = "acctestDBAC240112034207943198"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
