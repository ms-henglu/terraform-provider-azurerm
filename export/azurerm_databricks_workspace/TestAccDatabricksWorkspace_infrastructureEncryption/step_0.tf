
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-databricks-240119024832322323"
  location = "West Europe"
}

resource "azurerm_databricks_workspace" "test" {
  name                = "acctestDBW-240119024832322323"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "premium"

  infrastructure_encryption_enabled = true
}
