
			
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231016033359685737"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-231016033359685737"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "test" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "test" {
  name                = "acctestpip-231016033359685737"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-231016033359685737"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.test.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.test.id
  }
}

resource "azurerm_network_security_group" "my_terraform_nsg" {
  name                = "myNetworkSecurityGroup"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface_security_group_association" "example" {
  network_interface_id      = azurerm_network_interface.test.id
  network_security_group_id = azurerm_network_security_group.my_terraform_nsg.id
}

resource "azurerm_linux_virtual_machine" "test" {
  name                            = "acctestVM-231016033359685737"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd3806!"
  provision_vm_agent              = false
  allow_extension_operations      = false
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.test.id,
  ]
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}


resource "azurerm_arc_kubernetes_cluster" "test" {
  name                         = "acctest-akcc-231016033359685737"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAqImptGY0LfHaz8FHUEGNGpc4MJRMQqlD2U+XfrL/GBCH4eqcH3j+5lSyLmvU6gWdAF8teJR7j1KNuR5/4krSasxYkbpGfCsJ1g4eQIPdtI9E1s43O4UlM0/Ca9wgKl/JmIsoWrSCcRqDBLXtEYqkndF+lsm9Qa1UIQivdA388m/Z5IjDg2KFDpap8hyI9IM9VmbIoofUW5mGr3EwvB1OkAYX+r8zwYmj40sapezQ0fiyKHAZlN0x6/RPp0YeBCnjPsKO8x3uJ+Dgbpz8gCJ/0Z13Y62/yXu1hvN1CLqgOPMKPR4YrJpLodCg2NBYUFJGxnlk/t8zpkQXLPCFitE4ClKdzW0Er5S2VGJ2f8CV+XKtqXsOAS89KgBg96iiFp/sXNnLLSghsW0xooJ32Eoz2RLZFJyXtPbtfUA7UKqvs22sZcU+KAo5XcaJ467RKdM8KP414ohsO+eZ08GNPoHYTJa/AD7GmnW60VCBLYWIPFhDiWPW8i6zOLJKGE63AiuO1MciX9PKa5TGyhVa86lLegAiKsgVOo5mxdVKAa7/myaBkKmtADxGErBLkmv8t0xGQqv21YXS8TmL4Qx2UXIiaRjpz2tbKpRC7qxKMmi6YCbpt/3s0WQP/wI6hc2/kBv7sJ2i2n7A7/iccDkWvEYBzZUkkab8pBkxTzyPtNKqVMUCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd3806!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-231016033359685737"
    location            = azurerm_resource_group.test.location
    tenant_id           = "ARM_TENANT_ID"
    working_dir         = "/home/adminuser"
  })
  destination = "/home/adminuser/install_agent.sh"
}

provisioner "file" {
  source      = "testdata/install_agent.py"
  destination = "/home/adminuser/install_agent.py"
}

provisioner "file" {
  source      = "testdata/kind.yaml"
  destination = "/home/adminuser/kind.yaml"
}

provisioner "file" {
  content     = <<EOT
-----BEGIN RSA PRIVATE KEY-----
MIIJJwIBAAKCAgEAqImptGY0LfHaz8FHUEGNGpc4MJRMQqlD2U+XfrL/GBCH4eqc
H3j+5lSyLmvU6gWdAF8teJR7j1KNuR5/4krSasxYkbpGfCsJ1g4eQIPdtI9E1s43
O4UlM0/Ca9wgKl/JmIsoWrSCcRqDBLXtEYqkndF+lsm9Qa1UIQivdA388m/Z5IjD
g2KFDpap8hyI9IM9VmbIoofUW5mGr3EwvB1OkAYX+r8zwYmj40sapezQ0fiyKHAZ
lN0x6/RPp0YeBCnjPsKO8x3uJ+Dgbpz8gCJ/0Z13Y62/yXu1hvN1CLqgOPMKPR4Y
rJpLodCg2NBYUFJGxnlk/t8zpkQXLPCFitE4ClKdzW0Er5S2VGJ2f8CV+XKtqXsO
AS89KgBg96iiFp/sXNnLLSghsW0xooJ32Eoz2RLZFJyXtPbtfUA7UKqvs22sZcU+
KAo5XcaJ467RKdM8KP414ohsO+eZ08GNPoHYTJa/AD7GmnW60VCBLYWIPFhDiWPW
8i6zOLJKGE63AiuO1MciX9PKa5TGyhVa86lLegAiKsgVOo5mxdVKAa7/myaBkKmt
ADxGErBLkmv8t0xGQqv21YXS8TmL4Qx2UXIiaRjpz2tbKpRC7qxKMmi6YCbpt/3s
0WQP/wI6hc2/kBv7sJ2i2n7A7/iccDkWvEYBzZUkkab8pBkxTzyPtNKqVMUCAwEA
AQKCAgA8/IunVvB8y67VTOhkV0QbIitYEOHDoYKGyXFVjKoYaCrzijTygpMif/V2
LNj/0gYtE0PeBUTs6P+VxD6cgVzA/q7yFMjat6w4hCVYTR9V7h4H6Nk9tYFvnuYI
p8AP9Vd61qhEolstWF2ev8JIfbXx0dQP9nKAqJrv1TfANCubAvSC6SZujaD+VXCr
xr2cVT1F3a2uep5Sgyykob3z5FsAbOQSfUvaNddTMWM0NYye3nKBhYcMQjqFWoPU
UOAdu5aaqEaYHPWIAqzT+gS4zUMZc/S24jGrVBOtAL4R6Y5+7RuAYDqngrHpnRgH
POUoM42e1mDAhb4n5S3JukNopyqyoyyPnYTMKuaUD8W4WSaM7tNmFRbu7en3UTZS
WrBo2kVuYcM4uEXoEdorSC/meTLYa7VvW08qCKAPalekF5Z9aCR3jL432vrCA8G7
Gmff/be03hHL3m71/ziZ+03S7Jhzr5L8XAqdwC2tzQg8abdQCEJ0mhUaS52oa95A
w9sGWTOwvvNdBKDlNm19nYMN8pRzNkm3wzvs05/5gQAK6K9NRw0h+Aax4I6mX4TM
2RjsDEnU1+ordFk8OVWOlkdsaAVR3WdQX3wQdEZ58k09vVB+ltbvcDhRXmVxbazY
+uLv0z9ie1vGNwuYAsFDGjRnVIxs7cowvV1aHj60SCix9uZPgQKCAQEA1cnDhmiZ
xONp3OV61sFx2YIMOfmWVy28Qc6MyDxEfxa9ETj63KZbm0NYAx5l9EHUnhHOYQDW
rC/JXjB9MtavdHFUT4DwoYEhSl1bWaJkjxowt82vRtn3s/TqG+aGBtwxuzVDGJid
xcxwX99nXf1uMYiwIrsRUahSUfbOcN0JTS2JhoHoYhf2asG1Sam9/vKv2PoSR86c
v39AharEfX4OqsNbF6xLijhRZvYTrvUdyVLQ6uI6VB99wkE2kqPzbq8rp1bcHLhN
GqLHDODSmoq1JjcVHM6MbSfVw6tzcTdq0wGwxvupiZJjLcuHx7ujrAbS4YUodP6t
klIu8JCcRAiwpQKCAQEAydCmv8w5DKqbx8CJbrSFo/CnXR0jr5ou6pupnbszyC8e
BDTFx5VeZM2UxeRN9Lv4v6GqE8AtMZ7RchwdXgUn3tPv/lx/tfuNlMy9kk2sBXjJ
WipNnVyiB1XsrnN/H3C6wC03hPKr7B5fcU5jyA3K8yhXpT7DZYL7QjYSIbBHu8Ky
TdPnhvbCKQ0wDXrJrXkZ1SYb4WECWzqV9PuGdgTLA5/MyG8d3fjpMXb0ha0YEXHA
56O7Mf7sKDjCEz+491Sa/q601uqhR4F+t85TyOTqJiZ5DDE9imutPho+IzDA7F1/
m/KppWuzxMohXqzfRUETcO5IgKGu8JDhHbVYGZy5oQKCAQBbyfbi/IIY4LMRHo3x
Krkg9A8fzSNZZs+PSYl0ZzvZfP/MJzS+C8cFEJL3M9P+XU1WWLrNNzj0UMgaYqM+
cqJ+UjIquGeYUALlFNQl1e1q64nDQNJijy8k2qCxPfaJd3z6rdGS++OxiycsYpTU
6/yl09Qb9UloT+aYPmlAWAaoVkbXs2r8wuEP0P9vEyv6DGSnuiajIfh218HyIfGf
F8JgWuP/dAAy5h89H6Yv1hnl2GLOljcI60RpZOpzZ2UbPqZ1gHuc8RxZtU3VH6oM
pEVGlRvBdIUiUJodGr3D/FEnK3Ck3mRaJrnibaJshQmu0Hc2UJ+gK8CGNDbnHo+Z
PknpAoIBAB3TvrFeJ5hdpsRxCl7YQ2Alczbp1ZpgeUqnUvxC7LZLcG5CtnB2/Qp8
794HjhX7qhn4dMCSiJtq052/1f9NV8UxIalAVoe49AXn9KSo4iG05l1zHyGAzVm0
M1TdMQ6ehJtek3QMwagWHRkL8udgUnx5m+qKSiq4nxX8E9XyzcdMUTn7dZ6W3b9f
eZikayY+XbkI9tnqkoSVNhCNFCRhNPgGKCf/dDSYUy7CXAVdvc7mNxKFOmd7O7/+
E4DwzA+R6450l7mj185Pr0DPN8bbPlgBG6bXqDbLD0G8cy6USA8nCnMr/DK8pkcR
cLkjZ6Q+p/bq4MBSJR7c6siPQsQWS8ECggEAFnViVokddjIKZbDnao9Wpcyix4NQ
mrzWSxZi8DkgBuIoNP5X6VU7i7zC142UqrYpWEfmM7MK+RBwpQUZClwuCYPlCNJh
S21vOHS9s6ZmHuggjKtaqzvJ3eMp6iWcrkJ2qvWkOwM9DeRNoSODucOIbZa7vwyD
9sJMv1DyUEkB+FgRb6wmRAp8nTklsTHEZU1UzDBYqb2ZbvRbsZiOWTf+ZjhWXSIu
8+6nbbmbfhyj0QDL3T6rzt8g11WJ0zV4U2lR9lVUH4MnC97hB9Tx7cUsJzMPeqdJ
ugpkxjqyRGGTCmMO96cNQg0WYh0VxZLG3IYY8vo0SOJMU4zULEAB36PJ8g==
-----END RSA PRIVATE KEY-----

EOT
  destination = "/home/adminuser/private.pem"
}

provisioner "remote-exec" {
  inline = [
    "sudo sed -i 's/\r$//' /home/adminuser/install_agent.sh",
    "sudo chmod +x /home/adminuser/install_agent.sh",
    "bash /home/adminuser/install_agent.sh > /home/adminuser/agent_log",
  ]
}


  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}


resource "azurerm_arc_kubernetes_cluster_extension" "test" {
  name           = "acctest-kce-231016033359685737"
  cluster_id     = azurerm_arc_kubernetes_cluster.test.id
  extension_type = "microsoft.flux"

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}


resource "azurerm_arc_kubernetes_flux_configuration" "test" {
  name       = "acctest-fc-231016033359685737"
  cluster_id = azurerm_arc_kubernetes_cluster.test.id
  namespace  = "flux"

  git_repository {
    url             = "https://github.com/Azure/arc-k8s-demo"
    reference_type  = "branch"
    reference_value = "main"
  }

  kustomizations {
    name = "kustomization-1"
  }

  depends_on = [
    azurerm_arc_kubernetes_cluster_extension.test
  ]
}


resource "azurerm_arc_kubernetes_flux_configuration" "import" {
  name       = azurerm_arc_kubernetes_flux_configuration.test.name
  cluster_id = azurerm_arc_kubernetes_flux_configuration.test.cluster_id
  namespace  = azurerm_arc_kubernetes_flux_configuration.test.namespace

  git_repository {
    url             = "https://github.com/Azure/arc-k8s-demo"
    reference_type  = "branch"
    reference_value = "main"
  }

  kustomizations {
    name = "kustomization-1"
  }

  depends_on = [
    azurerm_arc_kubernetes_cluster_extension.test
  ]
}
