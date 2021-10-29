
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "cxtcnmpxdgcbduyp7ofyjiiful31f2hn04ndd86i0"
  token_secret = "ximgeai9x7q0km7b6exc1t4rqynipgdg7x7qcrwpr"
}
