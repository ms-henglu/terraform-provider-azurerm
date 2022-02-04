
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220204092645796921"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "1e8873bd-686d-4fe5-91fa-9caf3e0dc738"
  name               = "acctestrd-220204092645796921"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
