
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "1wswpog8surmiize2w4xyxg1nwwylofkc08cbjo8f"
  token_secret = "z8dxd1gueq6ghyjlg6ntkbyglux8zwdly8th2q0y7"
}
