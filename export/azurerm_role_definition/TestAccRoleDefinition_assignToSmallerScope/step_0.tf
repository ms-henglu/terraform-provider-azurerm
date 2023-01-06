
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230106034122349178"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "64604958-2d9f-47ef-922a-855664ef6d7c"
  name               = "acctestrd-230106034122349178"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
