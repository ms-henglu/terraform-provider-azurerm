
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220107063642726296"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "885fb7fb-9627-426e-a426-d325864e7900"
  name               = "acctestrd-220107063642726296"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
