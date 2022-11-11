
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "lsebb4m920t841qbv88a3dx04l4ifhtq4iyql2b6j"
  token_secret = "mfw6ork0avv3rskv14m3dxwpf9ngp4lxwlry6hzae"
}
