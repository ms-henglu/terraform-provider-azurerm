
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-databricks-230613071701496649"
  location = "West Europe"
}


resource "azurerm_databricks_access_connector" "test" {
  name                = "acctestDBAC230613071701496649"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
