
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-databricks-221221204154666230"
  location = "West Europe"
}

resource "azurerm_databricks_access_connector" "test" {
  name                = "acctestDBAC221221204154666230"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  identity {
    type = "SystemAssigned"
  }
}
