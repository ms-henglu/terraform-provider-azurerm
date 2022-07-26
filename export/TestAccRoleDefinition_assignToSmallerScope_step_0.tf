
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220726014514616841"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "a8ba09d1-b7ff-4cb1-a6b5-67c42a8451b6"
  name               = "acctestrd-220726014514616841"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
