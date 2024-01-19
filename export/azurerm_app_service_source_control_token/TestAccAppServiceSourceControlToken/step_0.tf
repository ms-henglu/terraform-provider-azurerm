
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "vj9z6p87wnbbbwimd6jcy8jn4gkh6olb9cqevctck"
  token_secret = "pjdab6ifmp9c7va0a1r3shqfvjzmns2umtsu2mgxv"
}
