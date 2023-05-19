
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230519074214083270"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "ff04fc2c-e8c1-4e25-bb47-6ad03b5555fd"
  name               = "acctestrd-230519074214083270"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
