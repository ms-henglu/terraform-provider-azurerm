
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "eqzjs4n6k48sww68yfq2aiorl97fi0ul6w4z82pq4"
  token_secret = "f6hf0uexr1issqf749dr0vdb11yjce3t6i6daa84f"
}
