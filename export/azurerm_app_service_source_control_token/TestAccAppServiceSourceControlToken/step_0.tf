
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "is0m4g7gx8lu9wcpa3akqwdmz3dj67p7debwwjzwr"
  token_secret = "7odcdg4gxsf91172o64ocetzbxwt9uafdzf69sp6a"
}
