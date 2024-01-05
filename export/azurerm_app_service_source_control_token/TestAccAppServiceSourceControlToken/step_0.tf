
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "6ods83vk3x0qrn606xv2edtwez8jc8vjx8lh7p1r6"
  token_secret = "d6284ffznw2albpkxd9y8idxyn9nlxsjl4axt7hgw"
}
