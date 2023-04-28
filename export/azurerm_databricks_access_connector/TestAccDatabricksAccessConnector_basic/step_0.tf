
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-databricks-230428045545185201"
  location = "West Europe"
}


resource "azurerm_databricks_access_connector" "test" {
  name                = "acctestDBAC230428045545185201"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
