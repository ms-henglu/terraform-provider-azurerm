
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "qbqzibuiv1ppcsv4w68qrlkd8p4gfyolbn0dxsyo1"
  token_secret = "alr879fnbadhy3xqlqvn1dbj7ftiemmdxkluthfmn"
}
