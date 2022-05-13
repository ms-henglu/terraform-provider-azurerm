
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "87zvhl6dpbvvkg7s8c4kaaxnhpuwlf18k3az7i6y2"
  token_secret = "qyjp9zvi6vgtgotou84jkmdt3gg3333g1k8y0bmg2"
}
