
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "74aoly8jjba8d23iwobhg6ypji2hj3ads4p4rrpou"
  token_secret = "x8lcske4a1yr18cqc11roiambd7040b7u0i2k1r0s"
}
