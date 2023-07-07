
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-databricks-230707003719009755"
  location = "West Europe"
}


resource "azurerm_user_assigned_identity" "test" {
  name                = "acctestDBUAI-230707003719009755"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_databricks_access_connector" "test" {
  name                = "acctestDBAC230707003719009755"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  identity {
    type = "UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.test.id,
    ]
  }
}
