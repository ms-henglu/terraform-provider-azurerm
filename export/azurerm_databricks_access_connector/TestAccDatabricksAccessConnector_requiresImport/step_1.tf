

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-databricks-230106034334814103"
  location = "West Europe"
}

resource "azurerm_databricks_access_connector" "test" {
  name                = "acctestDBAC230106034334814103"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  identity {
    type = "SystemAssigned"
  }
}


resource "azurerm_databricks_access_connector" "import" {
  name                = azurerm_databricks_access_connector.test.name
  resource_group_name = azurerm_databricks_access_connector.test.resource_group_name
  location            = azurerm_databricks_access_connector.test.location
  identity {
    type = "SystemAssigned"
  }
}
