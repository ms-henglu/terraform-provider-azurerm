
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231016033408700484"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "9d4c62d8-df29-4c5e-b0f6-c0c1b2241456"
  name               = "acctestrd-231016033408700484"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
