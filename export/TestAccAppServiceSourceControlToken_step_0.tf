
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "izlptfvg9w4bhq7brab1hpg6fwfa886lw3mkoa2jh"
  token_secret = "rn76g3gtt6r3bjhr49i7nbnprqvbnyxcd444j7o2w"
}
