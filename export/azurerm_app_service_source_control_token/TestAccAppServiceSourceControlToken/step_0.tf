
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "mbkr6nytxxcu6rbzjw36e0m1fy0sd0o8vswvyarax"
  token_secret = "ofr1tlvuydgpidxwioltq1ux7erlrq9dbzmbekkpm"
}
