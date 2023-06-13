
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "test" {
  subscription_id = ""
}

resource "azurerm_management_group" "test" {
}

resource "azurerm_management_group_subscription_association" "test" {
  management_group_id = azurerm_management_group.test.id
  subscription_id     = data.azurerm_subscription.test.id
}
