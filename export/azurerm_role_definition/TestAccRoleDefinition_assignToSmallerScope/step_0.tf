
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230428045223221469"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "d391c801-77b1-4164-99f3-71ad0acdbce3"
  name               = "acctestrd-230428045223221469"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
