
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220311042035093794"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "b66360be-4d6a-445a-803c-8880bc5ce245"
  name               = "acctestrd-220311042035093794"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
