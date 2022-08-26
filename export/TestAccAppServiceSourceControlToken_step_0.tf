
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "j2m7svbhf4nd0h1ws6emfhav0n3b9g2amf67wpf4b"
  token_secret = "ngzcro9d86g1gjo0wox1zd4iahgngs8p86udzk7m4"
}
