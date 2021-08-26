
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "bfxkg6lvb0y012h4i6pfayikwa2xh90xejnaza4kw"
  token_secret = "6y4sgssbauuwd6by0nrasq6vvh77vm0mefafkfvqk"
}
