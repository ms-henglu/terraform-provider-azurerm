
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "mcx9vtg0lugpmjqcv1uzj70s6vahxfsv8n6kd26d6"
  token_secret = "u7rn6sscptedxr0r4zr04z90k0qle4sy2n079refu"
}
