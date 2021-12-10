
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211210024315791582"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "470db3f5-66a8-4e3f-9154-d01dbbdc0295"
  name               = "acctestrd-211210024315791582"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
