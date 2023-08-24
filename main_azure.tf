terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.69.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "research_rg" {
  name     = "Research_RG"
  location = "West Europe"
}

resource "azurerm_virtual_network" "cloud_network" {
  name                = "Cloud_network"
  location            = azurerm_resource_group.research_rg.location
  resource_group_name = azurerm_resource_group.research_rg.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "cloud_subnet" {
  name                 = "cloud_subnet"
  resource_group_name  = azurerm_resource_group.research_rg.name
  virtual_network_name = azurerm_virtual_network.cloud_network.name
  address_prefixes     = ["10.0.1.0/24"]
}
# Creating a Public IP for the first VM
resource "azurerm_public_ip" "vm1_public_ip" {
  name                = "vm1-public-ip"
  resource_group_name = azurerm_resource_group.research_rg.name
  location            = azurerm_resource_group.research_rg.location
  allocation_method   = "Dynamic"
}

# Creating a network interface for the first VM
resource "azurerm_network_interface" "vm1_nic" {
  name                = "vm1-nic"
  location            = azurerm_resource_group.research_rg.location
  resource_group_name = azurerm_resource_group.research_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.cloud_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm1_public_ip.id
  }
}

# VM using Debian image for the first server
resource "azurerm_linux_virtual_machine" "vm1" {
  name                            = "web-server-vm1"
  resource_group_name             = azurerm_resource_group.research_rg.name
  location                        = azurerm_resource_group.research_rg.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "Password1234!"
  network_interface_ids           = [azurerm_network_interface.vm1_nic.id]
  disable_password_authentication = false

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Debian"
    offer     = "debian-10"
    sku       = "10-gen2"
    version   = "latest"
  }
}



# Creating a Public IP for the second VM
resource "azurerm_public_ip" "vm2_public_ip" {
  name                = "vm2-public-ip"
  resource_group_name = azurerm_resource_group.research_rg.name
  location            = azurerm_resource_group.research_rg.location
  allocation_method   = "Dynamic"
}

# Creating a network interface for the second VM
resource "azurerm_network_interface" "vm2_nic" {
  name                = "vm2-nic"
  location            = azurerm_resource_group.research_rg.location
  resource_group_name = azurerm_resource_group.research_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.cloud_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm2_public_ip.id
  }
}

# VM using Debian image for the second server
resource "azurerm_linux_virtual_machine" "vm2" {
  name                            = "web-server-vm2"
  resource_group_name             = azurerm_resource_group.research_rg.name
  location                        = azurerm_resource_group.research_rg.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "Password1234!"
  network_interface_ids           = [azurerm_network_interface.vm2_nic.id]
  disable_password_authentication = false

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Debian"
    offer     = "debian-10"
    sku       = "10-gen2"
    version   = "latest"
  }
}
