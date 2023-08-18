
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-databricks-230818023842670538"
  location = "West Europe"
}


resource "azurerm_user_assigned_identity" "test" {
  name                = "acctestDBUAI-230818023842670538"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_databricks_access_connector" "test" {
  name                = "acctestDBAC230818023842670538"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  identity {
    type = "UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.test.id,
    ]
  }
}
