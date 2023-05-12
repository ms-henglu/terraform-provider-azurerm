
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230512003439943972"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "e5abf39a-e3f5-41aa-9a96-cd0ed57c0fe9"
  name               = "acctestrd-230512003439943972"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
