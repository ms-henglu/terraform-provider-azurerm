


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestrg-appliances-230929064335195835"
  location = "West Europe"
}


resource "azurerm_arc_resource_bridge_appliance" "test" {
  name                    = "acctestrcapplicance-230929064335195835"
  location                = azurerm_resource_group.test.location
  resource_group_name     = azurerm_resource_group.test.name
  distro                  = "AKSEdge"
  infrastructure_provider = "VMWare"
  public_key_base64       = "MIICCgKCAgEA14ZnxMP/CsH4dswA0itmSlB22km1lHtN2/bfULZBcoFW97lxT4S2DB5ZRIcjRvt6xJWE68fIJHEur1vMEzX0nmG5cIEkytVsysa0FKsMAFzTurpMl48uQX8BA61KqaWHd1EXt3mzVCL9iZR3u9XTrUucURJJfvrbigHoCFe30Qy4C0IZ0cEnujjiVs5z3cMFEtm6lqR4mP6F7zElylqpI5E0UvgRQsOGq4WGkRSIB6xrwN+BVF9Bwhsy9MCgSQLhnj+oBEnxh8jIdVY965KKFei1ntE8lQJc8sCtKqvWLeUZMZToh4pFtue5skvyvS5/vWYZuCh0Y1TRcUVyMiiAqnGxUzKQjYK2CpEzRRI+7ypc62/7A6JUt4LiNdyJe+ieXhR7QEAMQcY/Q9aj8C1m1lzRHkQKd33Wh1PHqZhdiApw1M5t27HwvzoL1MoH+M2uIVtuWzd92Dxu0sNyGfWNyWUyjo5cfu/AWuameCRNk6ERRV6NWWq+/xNV7T5q8oKcwH3U8UXbxNMtFvJdpCx5NP+4e4yEdE7aLuUcFb4p7+RPBjqszCWDm6m9WPpAsyF0xShGU/DaaXcGdk61TU0LrVKTRZslOAczdqcTleGaBtM6MavfmiOFJOHqGaOHRcKluHab3ArMguTAY94a7lSKgdU5ndqRw0VruY+xx89GgmMCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }
  tags = {
    "hello" = "world"
  }
}
