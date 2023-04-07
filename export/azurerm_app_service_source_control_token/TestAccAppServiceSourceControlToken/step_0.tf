
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "q8kg1copplmwjstv0da8vnjyi1ac96q9ai9jd06fr"
  token_secret = "1yxczsnw39snb7n8y0jvpegboe2e3v6zzhc0ezi4k"
}
