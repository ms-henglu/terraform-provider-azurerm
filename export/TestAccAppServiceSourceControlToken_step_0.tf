
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "14bvyco86i4hlqwrkliopmc0udwz738lk9nnrw7up"
  token_secret = "v9wk4bjy3dddus1kk0rbyp7l7cira862uzz1u6zye"
}
