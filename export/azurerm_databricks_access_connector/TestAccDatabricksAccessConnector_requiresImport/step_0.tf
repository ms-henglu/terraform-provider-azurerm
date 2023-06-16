
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-databricks-230616074603711557"
  location = "West Europe"
}


resource "azurerm_databricks_access_connector" "test" {
  name                = "acctestDBAC230616074603711557"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
