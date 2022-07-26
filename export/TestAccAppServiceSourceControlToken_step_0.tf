
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "8jm0n1qsps1hlqlq7umq1ijgpwi9sfxg3i16y31qo"
  token_secret = "mievyueotoilztz2ckb07vx38dvrvew1vowzq79z7"
}
