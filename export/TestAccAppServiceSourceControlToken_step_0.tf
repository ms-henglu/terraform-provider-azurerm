
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "vywwsns4y6cut7mbuvn6mzrtplim4ayxwphkq3et0"
  token_secret = "18t1pfr34wasik8lxi8mcdjad9ykhm837fpqpg9q6"
}
