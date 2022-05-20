
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220520053602062628"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "85a588b2-a99e-4fd2-9d9a-1869657142db"
  name               = "acctestrd-220520053602062628"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
