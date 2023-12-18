

data "azurerm_client_config" "test" {
}

resource "azurerm_marketplace_role_assignment" "test" {
  name                 = "bf6176a4-3737-4577-979a-b1b1060c955f"
  role_definition_name = "Managed Applications Reader"
  principal_id         = data.azurerm_client_config.test.object_id

  lifecycle {
    ignore_changes = [
      role_definition_id,
    ]
  }
}


resource "azurerm_marketplace_role_assignment" "import" {
  name                 = azurerm_marketplace_role_assignment.test.name
  role_definition_name = azurerm_marketplace_role_assignment.test.role_definition_name
  principal_id         = azurerm_marketplace_role_assignment.test.principal_id

  lifecycle {
    ignore_changes = [
      role_definition_id,
    ]
  }
}
