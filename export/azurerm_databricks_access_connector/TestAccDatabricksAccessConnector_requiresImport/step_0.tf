
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-databricks-230227032531157416"
  location = "West Europe"
}

resource "azurerm_databricks_access_connector" "test" {
  name                = "acctestDBAC230227032531157416"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
