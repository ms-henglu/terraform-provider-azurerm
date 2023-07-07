
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230707005952139365"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "09342f2f-9876-4be7-8e46-3fabfef1f43f"
  name               = "acctestrd-230707005952139365"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
