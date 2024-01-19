
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-databricks-240119021859481366"
  location = "West Europe"
}


resource "azurerm_databricks_access_connector" "test" {
  name                = "acctestDBAC240119021859481366"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
