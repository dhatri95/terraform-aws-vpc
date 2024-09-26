##project##
variable "env" {
  default = ""
}

variable "project" {
    default = ""
  
}

variable "common_tags" {
    type=map
  
}

##vpn##
variable "cidr" {
    type = string
    default = "10.0.0.0/16"
  
}

variable "dns_hostnames" {
    type = bool
    default = true
  
}

variable "vpn_tags" {
    default = {}    
}

##igw##

variable "igw_tags" {
    type = map
    default = {}
  
}
  
##public subnet##
variable "public_sb_tags" {
    default = {}  
}

variable "pb_cidrs" {
    default = []
    validation {
      condition = length(var.pb_cidrs)==2
      error_message = "Please enter two valid public subnet cidrs"
    }
  
}

variable "pv_cidrs" {
    default = []
    validation {
      condition = length(var.pv_cidrs)==2
      error_message = "Please enter two valid public subnet cidrs"
    }
  
}

variable "db_cidrs" {
    default = []
    validation {
      condition = length(var.db_cidrs)==2
      error_message = "Please enter two valid public subnet cidrs"
    }
  
}

variable "db_subnet_grp_tags" {
  default = {}
}

variable "eip_tags" {
    default = {}    
}

variable "nat_tags" {
    default = {}    
}


variable "accepter_id" {
    default = {}
  
}

variable "is_peering_required" {
    type = bool
}

variable "accepter_cidr" {
    default = {}
  
}

variable "peering_tags" {
    default = {}    
}