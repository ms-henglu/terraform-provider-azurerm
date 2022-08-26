
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "vt2myf0yzhoxg1k4z3yqnpb3srig3vf34y8j9ybiz"
  token_secret = "mbaqbp27a8qnmcdwv07h4vqydgbsh6ekbhulianjq"
}
