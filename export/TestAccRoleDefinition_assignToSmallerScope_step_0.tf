
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220715014156307816"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "51f2c695-e567-4a70-9e7d-436cbe9300e3"
  name               = "acctestrd-220715014156307816"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
