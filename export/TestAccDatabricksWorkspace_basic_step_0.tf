
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-databricks-211013071732995003"
  location = "West Europe"
}

resource "azurerm_databricks_workspace" "test" {
  name                = "acctestDBW-211013071732995003"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "standard"
}
