
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-databricks-231016033729500655"
  location = "West Europe"
}


resource "azurerm_databricks_access_connector" "test" {
  name                = "acctestDBAC231016033729500655"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
