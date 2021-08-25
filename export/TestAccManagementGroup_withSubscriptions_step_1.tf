
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  subscription_ids = [
    "ARM_SUBSCRIPTION_ID",
  ]
}
