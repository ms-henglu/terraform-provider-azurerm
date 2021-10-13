
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-databricks-211013071733002638"
  location = "West Europe"
}

resource "azurerm_databricks_workspace" "test" {
  name                = "acctestDBW-211013071733002638"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "premium"

  infrastructure_encryption_enabled = true
}
