
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "1guc2zvhati3fe0h3mnvpbm0lvom1doa1gu0fv8b0"
  token_secret = "ozjj8mho19hspli3vtmbw89k8s0x1yiv9idarxr9l"
}
