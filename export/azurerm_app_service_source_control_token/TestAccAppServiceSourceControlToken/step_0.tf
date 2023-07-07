
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "2i0qav13zoq0a3i3diwe9e8qxved9vhsqzt2oce4f"
  token_secret = "tit11d6fiaczd2f0u93hl1ec0exzlb18uwnqkbdyy"
}
