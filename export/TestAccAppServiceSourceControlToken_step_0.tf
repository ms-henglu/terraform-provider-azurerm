
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "adc6pv17v3nmfnpevbnm9boqw4g3y48f7ua7eeoiw"
  token_secret = "78v88hdfdmdrkik6xdelo6bqgjxga6n8tzmmpuwkb"
}
