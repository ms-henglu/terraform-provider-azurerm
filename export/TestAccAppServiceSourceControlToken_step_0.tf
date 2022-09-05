
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "u67q0ppqu9ar77oqldd1o74qy3zf7a1sqcepr2eak"
  token_secret = "86ywf1gfv8x9j3fylm0z70nmt072jnanxbirww6r0"
}
