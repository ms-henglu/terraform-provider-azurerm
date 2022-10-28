
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "mjm1tt3t40gaxerj0assve181p9jxq0yspolt11w8"
  token_secret = "edbrwxly3qibyqr3e7h1fvwibiqtrdluyok7bunfu"
}
