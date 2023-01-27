
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230127045005241750"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "2da62db9-98f3-4bfd-a8e6-a8e6e8d3ad0a"
  name               = "acctestrd-230127045005241750"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
