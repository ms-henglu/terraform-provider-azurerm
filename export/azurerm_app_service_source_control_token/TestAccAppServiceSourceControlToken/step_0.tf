
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "6mb7ploznwolt38scl2h31b00dppgaxgc8l8denep"
  token_secret = "u1komhavcqvu3qe6aedsvm9u33hlvb9qs9mfl6zr9"
}
