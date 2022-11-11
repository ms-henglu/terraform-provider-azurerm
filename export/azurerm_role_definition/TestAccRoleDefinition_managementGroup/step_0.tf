
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_management_group" "test" {
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "5162b73f-edc4-4c3e-a544-24bc89a02211"
  name               = "acctestrd-221111013108642569"
  scope              = azurerm_management_group.test.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_management_group.test.id,
    data.azurerm_subscription.primary.id,
  ]
}
