

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-databricks-221221204154665135"
  location = "West Europe"
}

resource "azurerm_databricks_workspace" "test" {
  name                = "acctestDBW-221221204154665135"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "standard"
}


resource "azurerm_databricks_workspace" "import" {
  name                = azurerm_databricks_workspace.test.name
  resource_group_name = azurerm_databricks_workspace.test.resource_group_name
  location            = azurerm_databricks_workspace.test.location
  sku                 = azurerm_databricks_workspace.test.sku
}
