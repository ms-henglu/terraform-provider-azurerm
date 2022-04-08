
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "9pp2kj3wb8x3hmnn84scohto3mhgkwwvgxgcaex1s"
  token_secret = "fy4dxhe6vjk13dlmj9ro2a6mt0ohr2vimxjqg4y6w"
}
