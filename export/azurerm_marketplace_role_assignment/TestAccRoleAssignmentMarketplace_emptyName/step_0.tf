
data "azurerm_client_config" "test" {}

data "azurerm_role_definition" "test" {
  name = "Reader"
}

resource "azurerm_marketplace_role_assignment" "test" {
  role_definition_id = "${data.azurerm_role_definition.test.id}"
  principal_id       = "${data.azurerm_client_config.test.object_id}"
  description        = "Test Role Assignment"

  lifecycle {
    ignore_changes = [
      name,
      role_definition_name,
    ]
  }
}
