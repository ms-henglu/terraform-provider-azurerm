
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "me17r2kwdcmp3o2w86ei0t3rku0fuv4pdeasm9dsm"
  token_secret = "q4b2xu00yb1fykypnjuew6vgf7kauaz4le63oawng"
}
