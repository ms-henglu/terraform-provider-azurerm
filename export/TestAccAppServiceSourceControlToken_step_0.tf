
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "w90tj1tq8euokcj8rr6zg34qule7h2kc0e4wjfvyl"
  token_secret = "3e489nf1je163n9esl496tdovdolizu9rvzjv7xj2"
}
