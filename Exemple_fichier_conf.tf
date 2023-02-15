terraform {
required_providers {
azurerm = {
source = "hashicorp/azurerm"
version = "~>2.0"
}
}
}

provider "azurerm" {
features {}

subscription_id = "92f4c11c-1587-4982-a01a-9d23488c10f1"
tenant_id = "c371d4f5-b34f-4b06-9e66-517fed904220"
client_id = "3b828e0a-3cb2-47d2-b249-7a23c43ae36d"
client_secret = "4ag8Q~TcpNcHLlMpPm3j4X2azbl2-EwiccaSTcfT"
}

##Resource Group
resource "azurerm_resource_group" "rg" {
name = "RG_FYC"
location = "france central"
}

##Avaibility Set
resource "azurerm_availability_set" "DemoAset" {
name = "AS_FYC"
location = azurerm_resource_group.rg.location
resource_group_name = azurerm_resource_group.rg.name
}

##Virtual Network
resource "azurerm_virtual_network" "vnet" {
name = "Vnet_FYC"
address_space = ["10.0.0.0/16"]
location = azurerm_resource_group.rg.location
resource_group_name = azurerm_resource_group.rg.name
}

##Subnet
resource "azurerm_subnet" "subnet" {
name = "SSR_FYC"
resource_group_name = azurerm_resource_group.rg.name
virtual_network_name = azurerm_virtual_network.vnet.name
address_prefixes = ["10.0.1.0/24"]
}

##Network interface
resource "azurerm_network_interface" "example" {
name = "IFR_FYC"
location = azurerm_resource_group.rg.location
resource_group_name = azurerm_resource_group.rg.name

ip_configuration {
name = "IP_FYC"
subnet_id = azurerm_subnet.subnet.id
private_ip_address_allocation = "Dynamic"
}
}

##Azure Virtual Machine
resource "azurerm_windows_virtual_machine" "example" {
name = "VMFYC"
resource_group_name = azurerm_resource_group.rg.name
location = azurerm_resource_group.rg.location
size = "Standard_F2"
admin_username = "FYC"
admin_password = "Azertyuiop@2023!"
availability_set_id = azurerm_availability_set.DemoAset.id
network_interface_ids = [
azurerm_network_interface.example.id,
]

os_disk {
caching = "ReadWrite"
storage_account_type = "Standard_LRS"
}

source_image_reference {
publisher = "MicrosoftWindowsServer"
offer = "WindowsServer"
sku = "2022-Datacenter"
version = "latest"
}
}