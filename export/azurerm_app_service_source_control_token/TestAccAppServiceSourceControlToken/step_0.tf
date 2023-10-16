
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "ibljpodfzb80rkyhwjijhh4azizwhx1prwhaelh8p"
  token_secret = "3r01avuimtpnew9g9q0lsa84j80bk70nnna733u2d"
}
