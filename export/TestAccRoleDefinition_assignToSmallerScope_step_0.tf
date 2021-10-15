
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211015014329812776"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "1898200d-2c3c-461d-b89b-5e1b4a65da39"
  name               = "acctestrd-211015014329812776"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
