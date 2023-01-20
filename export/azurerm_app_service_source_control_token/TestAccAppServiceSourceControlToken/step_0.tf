
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "mqlhbejnt0dzo07ml0goi6mv46bzbei6cukfx6w0f"
  token_secret = "zjftay9u7h9sqic37czfke3vv7jxjob2a7ef967y1"
}
