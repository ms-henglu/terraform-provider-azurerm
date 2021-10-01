
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "2liltk8yw6svzoe0uylzuoxualxftjmnaqypr1hfg"
  token_secret = "1sbixww1042tyfpu91ffqv4bpyul8avthp6m4kqoq"
}
