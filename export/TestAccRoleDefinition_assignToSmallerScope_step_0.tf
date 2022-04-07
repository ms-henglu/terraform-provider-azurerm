
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220407230703786386"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "2645524d-794e-463d-8f75-2cc0299a5edc"
  name               = "acctestrd-220407230703786386"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
