
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "brjdh3vu2q89kjruk9q3l8isqvrtfrjvz0aij1t2g"
  token_secret = "81b98cumz9q8wj61f2z991di2svng3mtyoppgvjoa"
}
