
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "jzwbugg8f7dl2icf2d0pt70urd3b9du4l7ddr3wix"
  token_secret = "ngcqyn4ezawqttwtw942r8pcglvsss1ijx1ostznh"
}
