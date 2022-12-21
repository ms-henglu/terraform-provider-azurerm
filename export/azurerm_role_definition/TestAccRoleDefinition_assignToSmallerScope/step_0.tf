
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221221203945892051"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "7f5e1454-d852-4a60-9291-96371687841b"
  name               = "acctestrd-221221203945892051"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
