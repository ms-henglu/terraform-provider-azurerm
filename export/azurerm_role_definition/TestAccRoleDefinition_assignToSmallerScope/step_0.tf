
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230512010230733125"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "43403828-d35c-47a8-9954-cfd7c5eda0fa"
  name               = "acctestrd-230512010230733125"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
