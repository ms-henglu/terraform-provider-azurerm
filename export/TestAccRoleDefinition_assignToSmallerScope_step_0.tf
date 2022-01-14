
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220114063834260013"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "c882bf97-5a40-4c5e-ab55-8f9bffed678d"
  name               = "acctestrd-220114063834260013"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
