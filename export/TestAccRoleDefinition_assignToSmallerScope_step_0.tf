
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211022001656545218"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "2825c43c-b869-45ef-8cd8-9b8c9401f34b"
  name               = "acctestrd-211022001656545218"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
