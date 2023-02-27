
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230227032240765501"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "7351f805-e4ed-4dbe-a2a6-a38ae19875ff"
  name               = "acctestrd-230227032240765501"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
