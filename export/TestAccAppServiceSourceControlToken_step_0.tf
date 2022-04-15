
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "nwo8shtrcvioa9d86aeq9f2774n6ovthg69v6hkxv"
  token_secret = "1zp0n060674wfe9owhvzwun4s170d4umro1gyuncg"
}
