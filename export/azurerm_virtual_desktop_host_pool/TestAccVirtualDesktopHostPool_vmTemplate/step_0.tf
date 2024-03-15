
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-vdesktophp-240315122850606780"
  location = "West US 2"
}

resource "azurerm_virtual_desktop_host_pool" "test" {
  name                 = "acctestHPazxvy"
  location             = azurerm_resource_group.test.location
  resource_group_name  = azurerm_resource_group.test.name
  type                 = "Pooled"
  validate_environment = true
  load_balancer_type   = "DepthFirst"

  vm_template = <<EOF
  {
    "imageType": "Gallery",
    "galleryImageReference": {
      "offer": "WindowsServer",
      "publisher": "MicrosoftWindowsServer",
      "sku": "2019-Datacenter",
      "version": "latest"
    },
    "osDiskType": "Premium_LRS",
    "customRdpProperty": {
      "audioRedirectionMode": "dynamic",
      "redirectClipboard": true,
      "redirectDrives": true
    }
  }
  EOF
}
