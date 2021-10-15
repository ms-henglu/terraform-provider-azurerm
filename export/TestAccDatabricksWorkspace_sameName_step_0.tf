
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-databricks-211015014115417244"
  location = "West Europe"
}

resource "azurerm_databricks_workspace" "test" {
  name                = "acctestDBW-211015014115417244"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "standard"

  managed_resource_group_name = "acctestDBW-211015014115417244"
}
