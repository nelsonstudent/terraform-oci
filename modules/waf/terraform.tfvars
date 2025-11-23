# TF_VERS : <TF_VERS>
# ACCOUNT : <ACCOUNT>


# DEFINIÇÃO DA REGIÃO DEFAULT DA CONTA PARA CRIAÇÃO DOS COMPARTMENTS
default_region_account = "<DEFAULT_REGION_ACCOUNT>"


# DEFAULT-TAGS
common_tags = {
  Customer     = "CodCli"
  Managed_by   = "terraform"
  Created_by   = "<CREATED_USERNAME_DEV>"
  Created_Date = "<CREATE_DATE>"
}


# A TagNamespace informada abaixo é um pré requisito para executar o deploy do ambiente
# https://www.terraform.io/docs/providers/oci/d/identity_tag_namespaces.html
tag_cost_tracker = "Customer.ALL_RESOURCES"


# COMPARTMENT
compartment_id   = "ocid1.compartment.oc1..aaaaaxxxxxxx" # Substitua pelo OCID real do compartimento
compartment_name = "MV_CodCli"


# SUB-COMPARTMENTS
sub_compartments = [
  "CodCliADM",
  "CodCliPRD",
  "CodCliTST1"
]


# NETWORK
vcn = {
  cidr_block             = "<CidrVcn>.0/22"
  display_name           = "MVCodCliVCN"
  dns_label              = "MVCodCliVCN"
  local_peering_gateways = ["LPG-CLIENT-ADM"]
}


# VPN-IPSEC
vpns = {
  static_routing = [
    #{
    #  display_name            = "VPN_RNP_01"
    #  customer_equipment_name = "CPE_RNP_01"
    #  customer_equipment_ip   = "200.1.1.2"                                      #IP Publico do cliente
    #  network_cidrs           = ["10.0.0.0/19", "10.12.0.0/16", "172.20.0.0/24"] #IP da Rede do Cliente
    #  ike_version              = "V1" # V1 ou V2
    #}
  ]
  bgp_routing = [
    #{
    #  display_name             = "VPN_PROVEDOR_01_BGP"
    #  customer_equipment_name  = "CPE_PROVEDOR_01_BGP"
    #  customer_equipment_ip    = "100.210.220.30"
    #  ike_version              = "V2" # V1 ou V2
    #  customer_bgp_asn         = "65101"
    #  display_name_p1          = "Peer-1"
    #  customer_interface_ip_p1 = "169.254.0.1/30"
    #  oracle_interface_ip_p1   = "169.254.0.2/30"
    #  display_name_p2          = "Peer-2"
    #  customer_interface_ip_p2 = "169.254.0.5/30"
    #  oracle_interface_ip_p2   = "169.254.0.6/30"
    #}
  ]
}


# SUBNETS
subnets = {
  PUBLIC_CodCli = {
    subnet_cidrs     = "<SbntPub1>.0/24"
    private          = "false"
    route_table_name = "publicRouteTable"
    ingress = [
    ]
    egress = [
    ]
  }
  APP_CodCli = {
    subnet_cidrs     = "<SbntApp1>.0/24"
    private          = "true"
    route_table_name = "privateRouteTable"
    ingress = [
    ]
    egress = [
    ]
  }
  DB_CodCli = {
    subnet_cidrs     = "<SbntDB1>.0/24"
    private          = "true"
    route_table_name = "privateRouteTable"
    ingress = [
    ]
    egress = [
    ]
  }
}


# PUBLIC-IPS
public_ips_names = ["LB-MAIN-PUBLIC-A"]


# BLOCK-VOLUMES
block_volumes = {
  #"CodCli-BLOCK-DATA-01" = {
  #  compartment_name   = "CodCliPRD"
  #  size_in_gbs        = 50
  #  attachment_type    = "paravirtualized"
  #  backup_policy_name = "<POLICY_BKP_BLOCK_VOUME>"
  #}
}


# COMPUTE
instance_list = {
  public = [
    #{{MV_CORE_LB}}

  ]
  private = [
    #{{MV_CORE_APP}}

  ]
}


# DATABASES
databases_list = [
  #{{MV_CORE_DB}}

]


# SECURITY-GROUP
security_groups = {
  "nsgMonitoramento" = {
    ingress = [
      {
        description = "ICMP - Monitoramento"
        protocol    = "1"
        source      = "10.3.0.0/24"
        stateless   = "false"
      },
      {
        description = "ORACLE - Monitoramento"
        protocol    = "6"
        source      = "10.3.0.0/24"
        port_min    = "1521"
        port_max    = "1521"
        stateless   = "false"
      },
      {
        description = "HTTP - Monitoramento"
        protocol    = "6"
        source      = "10.3.0.0/24"
        port_min    = "80"
        port_max    = "85"
        stateless   = "false"
      },
      {
        description = "HTTPS - Monitoramento"
        protocol    = "6"
        source      = "10.3.0.0/24"
        port_min    = "443"
        port_max    = "443"
        stateless   = "false"
      },
      {
        description = "ZABBIX - Monitoramento"
        protocol    = "6"
        source      = "10.3.0.0/24"
        port_min    = "1024"
        port_max    = "65535"
        stateless   = "false"
      },
      {
        description = "HTTP - Monitoramento"
        protocol    = "6"
        source      = "159.112.184.4/32"
        port_min    = "80"
        port_max    = "80"
        stateless   = "false"
      },
      {
        description = "HTTPS - Monitoramento"
        protocol    = "6"
        source      = "159.112.184.4/32"
        port_min    = "443"
        port_max    = "443"
        stateless   = "false"
      }
    ]
    egress = [
      {
        description = "Full OutBound IPv4"
        protocol    = "all"
        destination = "0.0.0.0/0"
        stateless   = "false"
      }
    ]
  },
  "nsgFlwMV" = {
    ingress = [
      {
        description = "SSH From Flowti-BQE"
        protocol    = "6"
        source      = "177.200.192.146/32"
        port_min    = "22"
        port_max    = "22"
        stateless   = "false"
      },
      {
        description = "HTTP From Flowti-BQE"
        protocol    = "6"
        source      = "177.200.192.146/32"
        port_min    = "80"
        port_max    = "85"
        stateless   = "false"
      },
      {
        description = "HTTPS From Flowti-BQE"
        protocol    = "6"
        source      = "177.200.192.146/32"
        port_min    = "443"
        port_max    = "443"
        stateless   = "false"
      },
      {
        description = "SSH OCI-Administration NAT"
        protocol    = "6"
        source      = "152.67.39.218/32"
        port_min    = "22"
        port_max    = "22"
        stateless   = "false"
      },
      {
        description = "HTTP OCI-Administration NAT"
        protocol    = "6"
        source      = "152.67.39.218/32"
        port_min    = "80"
        port_max    = "85"
        stateless   = "false"
      },
      {
        description = "HTTPS OCI-Administration NAT"
        protocol    = "6"
        source      = "152.67.39.218/32"
        port_min    = "443"
        port_max    = "443"
        stateless   = "false"
      },
      {
        description = "ZABBIX OCI-Administration NAT"
        protocol    = "6"
        source      = "152.67.39.218/32"
        port_min    = "10050"
        port_max    = "10051"
        stateless   = "false"
      },
      {
        description = "SSH From WTSOCI-MV"
        protocol    = "6"
        source      = "129.159.59.32/32"
        port_min    = "22"
        port_max    = "22"
        stateless   = "false"
      },
      {
        description = "HTTP From WTSOCI-MV"
        protocol    = "6"
        source      = "129.159.59.32/32"
        port_min    = "80"
        port_max    = "85"
        stateless   = "false"
      },
      {
        description = "HTTPS From WTSOCI-MV"
        protocol    = "6"
        source      = "129.159.59.32/32"
        port_min    = "443"
        port_max    = "443"
        stateless   = "false"
      },
      {
        description = "SSH From VPN OCI"
        protocol    = "6"
        source      = "129.159.58.14/32"
        port_min    = "22"
        port_max    = "22"
        stateless   = "false"
      },
      {
        description = "HTTP From Flowti VPN OCI"
        protocol    = "6"
        source      = "129.159.58.14/32"
        port_min    = "80"
        port_max    = "85"
        stateless   = "false"
      },
      {
        description = "HTTPS From Flowti VPN OCI"
        protocol    = "6"
        source      = "129.159.58.14/32"
        port_min    = "443"
        port_max    = "443"
        stateless   = "false"
      }
    ]
    egress = [
      {
        description = "Full OutBound IPv4"
        protocol    = "all"
        destination = "0.0.0.0/0"
        stateless   = "false"
      }
    ]
  },
  "nsgLB-MV" = {
    ingress = [
      {
        description = "HTTP OCI-Administration NAT"
        protocol    = "6"
        source      = "152.67.39.218/32"
        port_min    = "80"
        port_max    = "85"
        stateless   = "false"
      },
      {
        description = "HTTPS OCI-Administration NAT"
        protocol    = "6"
        source      = "152.67.39.218/32"
        port_min    = "443"
        port_max    = "443"
        stateless   = "false"
      },
      {
        description = "HTTP From Flowti VPN OCI"
        protocol    = "6"
        source      = "129.159.58.14/32"
        port_min    = "80"
        port_max    = "85"
        stateless   = "false"
      },
      {
        description = "HTTPS From Flowti VPN OCI"
        protocol    = "6"
        source      = "129.159.58.14/32"
        port_min    = "443"
        port_max    = "443"
        stateless   = "false"
      },
      {
        description = "HTTP From WTSOCI-MV"
        protocol    = "6"
        source      = "129.159.59.32/32"
        port_min    = "80"
        port_max    = "85"
        stateless   = "false"
      },
      {
        description = "HTTPS From WTSOCI-MV"
        protocol    = "6"
        source      = "129.159.59.32/32"
        port_min    = "443"
        port_max    = "443"
        stateless   = "false"
      },
      {
        description = "HTTP From Flowti-BQE"
        protocol    = "6"
        source      = "177.200.192.146/32"
        port_min    = "80"
        port_max    = "85"
        stateless   = "false"
      },
      {
        description = "HTTPS From Flowti-BQE"
        protocol    = "6"
        source      = "177.200.192.146/32"
        port_min    = "443"
        port_max    = "443"
        stateless   = "false"
      },
      {
        description = "SSH - From Sbnt-Public"
        protocol    = "6"
        source      = "<SbntPub1>.0/24"
        port_min    = "22"
        port_max    = "22"
        stateless   = "false"
      },
      {
        description = "HTTP - From Sbnt-Public"
        protocol    = "6"
        source      = "<SbntPub1>.0/24"
        port_min    = "80"
        port_max    = "85"
        stateless   = "false"
      },
      {
        description = "HTTPS - From Sbnt-Public"
        protocol    = "6"
        source      = "<SbntPub1>.0/24"
        port_min    = "443"
        port_max    = "443"
        stateless   = "false"
      },
      {
        description = "SSH - From Sbnt-App"
        protocol    = "6"
        source      = "<SbntApp1>.0/24"
        port_min    = "22"
        port_max    = "22"
        stateless   = "false"
      },
      {
        description = "HTTP - From Sbnt-App"
        protocol    = "6"
        source      = "<SbntApp1>.0/24"
        port_min    = "80"
        port_max    = "85"
        stateless   = "false"
      },
      {
        description = "HTTPS - From Sbnt-App"
        protocol    = "6"
        source      = "<SbntApp1>.0/24"
        port_min    = "443"
        port_max    = "443"
        stateless   = "false"
      },
      {
        description = "License - From Sbnt-App"
        protocol    = "6"
        source      = "<SbntApp1>.0/24"
        port_min    = "5065"
        port_max    = "5065"
        stateless   = "false"
      },
      {
        description = "License - From Sbnt-App"
        protocol    = "17"
        source      = "<SbntApp1>.0/24"
        port_min    = "5065"
        port_max    = "5065"
        stateless   = "false"
      }
    ]
    egress = [
      {
        description = "Full OutBound IPv4"
        protocol    = "all"
        destination = "0.0.0.0/0"
        stateless   = "false"
      }
    ]
  },
  "nsgDB" = {
    ingress = [
      {
        description = "SSH - From Sbnt-Public"
        protocol    = "6"
        source      = "<SbntPub1>.0/24"
        port_min    = "22"
        port_max    = "22"
        stateless   = "false"
      },
      {
        description = "ORACLE - From Sbnt-Public"
        protocol    = "6"
        source      = "<SbntPub1>.0/24"
        port_min    = "1521"
        port_max    = "1521"
        stateless   = "false"
      },
      {
        description = "ORACLE - From Sbnt-App"
        protocol    = "6"
        source      = "<SbntApp1>.0/24"
        port_min    = "1521"
        port_max    = "1521"
        stateless   = "false"
      },
      {
        description = "CloneDB - From Sbnt-DB"
        protocol    = "6"
        source      = "<SbntDB1>.0/24"
        port_min    = "1521"
        port_max    = "1521"
        stateless   = "false"
      },
      {
        description = "CloneDB - From Sbnt-DB"
        protocol    = "6"
        source      = "<SbntDB1>.0/24"
        port_min    = "3782"
        port_max    = "3782"
        stateless   = "false"
      }
    ]
    egress = [
      {
        description = "Full OutBound IPv4"
        protocol    = "all"
        destination = "0.0.0.0/0"
        stateless   = "false"
      }
    ]
  }
  "nsgApp" = {
    ingress = [
       {
        description = "SSH - From Sbnt-App"
        protocol    = "6"
        source      = "<SbntApp1>.0/24"
        port_min    = "22"
        port_max    = "22"
        stateless   = "false"
      },
      {
        description = "RDP - From Sbnt-App"
        protocol    = "6"
        source      = "<SbntApp1>.0/24"
        port_min    = "3389"
        port_max    = "3389"
        stateless   = "false"
      },
      {
        description = "HTTP - From Sbnt-App"
        protocol    = "6"
        source      = "<SbntApp1>.0/24"
        port_min    = "80"
        port_max    = "85"
        stateless   = "false"
      },
      {
        description = "HTTPS - From Sbnt-App"
        protocol    = "6"
        source      = "<SbntApp1>.0/24"
        port_min    = "443"
        port_max    = "443"
        stateless   = "false"
      },
      {
        description = "WINRM - From Sbnt-App"
        protocol    = "6"
        source      = "<SbntApp1>.0/24"
        port_min    = "5985"
        port_max    = "5985"
        stateless   = "false"
      },
      {
        description = "License TCP - From Sbnt-App"
        protocol    = "6"
        source      = "<SbntApp1>.0/24"
        port_min    = "5065"
        port_max    = "5065"
        stateless   = "false"
      },
      {
        description = "License UDP - From Sbnt-App"
        protocol    = "17"
        source      = "<SbntApp1>.0/24"
        port_min    = "5065"
        port_max    = "5065"
        stateless   = "false"
      },
      {
        description = "SMB - From Sbnt-App"
        protocol    = "6"
        source      = "<SbntApp1>.0/24"
        port_min    = "139"
        port_max    = "139"
        stateless   = "false"
      },
      {
        description = "SMB - From Sbnt-App"
        protocol    = "6"
        source      = "<SbntApp1>.0/24"
        port_min    = "445"
        port_max    = "445"
        stateless   = "false"
      },
      {
        description = "Cartorio - From Sbnt-App"
        protocol    = "6"
        source      = "<SbntApp1>.0/24"
        port_min    = "8090"
        port_max    = "8092"
        stateless   = "false"
      },
      {
        description = "HTTP - From Sbnt-App"        
        protocol    = "6"
        source      = "<SbntApp1>.0/24"
        port_min    = "8000"
        port_max    = "10000"
        stateless   = "false"
      },
      {
        description = "SSH - From Sbnt-Public"
        protocol    = "6"
        source      = "<SbntPub1>.0/24"
        port_min    = "22"
        port_max    = "22"
        stateless   = "false"
      },
      {
        description = "RDP - From Sbnt-Public"
        protocol    = "6"
        source      = "<SbntPub1>.0/24"
        port_min    = "3389"
        port_max    = "3389"
        stateless   = "false"
      },
      {
        description = "HTTP - From Sbnt-Public"
        protocol    = "6"
        source      = "<SbntPub1>.0/24"
        port_min    = "80"
        port_max    = "85"
        stateless   = "false"
      },
      {
        description = "HTTPS - From Sbnt-Public"
        protocol    = "6"
        source      = "<SbntPub1>.0/24"
        port_min    = "443"
        port_max    = "443"
        stateless   = "false"
      },
      {
        description = "HTTP - From Sbnt-Public"
        protocol    = "6"
        source      = "<SbntPub1>.0/24"
        port_min    = "8000"
        port_max    = "10000"
        stateless   = "false"
      },
      {
        description = "HTTP - From Sbnt-Public"
        protocol    = "6"
        source      = "<SbntPub1>.0/24"
        port_min    = "18000"
        port_max    = "19999"
        stateless   = "false"
      },
      {
        description = "HTTP - From Sbnt-Public"
        protocol    = "6"
        source      = "<SbntPub1>.0/24"
        port_min    = "28000"
        port_max    = "29999"
        stateless   = "false"
      },
      {
        description = "HTTP - From Sbnt-Public"
        protocol    = "6"
        source      = "<SbntPub1>.0/24"
        port_min    = "38000"
        port_max    = "41000"
        stateless   = "false"
      },
      {
        description = "HTTP Green - From Sbnt-Public"
        protocol    = "6"
        source      = "<SbntPub1>.0/24"
        port_min    = "2443"
        port_max    = "2443"
        stateless   = "false"
      },
      {
        description = "HTTP Green - From Sbnt-Public"
        protocol    = "6"
        source      = "<SbntPub1>.0/24"
        port_min    = "3443"
        port_max    = "3443"
        stateless   = "false"
      },
      {
        description = "HTTP Global Health - From Sbnt-Public"
        protocol    = "6"
        source      = "<SbntPub1>.0/24"
        port_min    = "4443"
        port_max    = "4443"
        stateless   = "false"
      },
      {
        description = "HTTP - From Sbnt-Public"
        protocol    = "6"
        source      = "<SbntPub1>.0/24"
        port_min    = "11000"
        port_max    = "11000"
        stateless   = "false"
      },
      {
        description = "HTTP - From Sbnt-Public"
        protocol    = "6"
        source      = "<SbntPub1>.0/24"
        port_min    = "11200"
        port_max    = "11204"
        stateless   = "false"
      },
      {
        description = "HTTP - From Sbnt-Public"
        protocol    = "6"
        source      = "<SbntPub1>.0/24"
        port_min    = "11300"
        port_max    = "11300"
        stateless   = "false"
      },
      {
        description = "SMB - From Sbnt-DB"
        protocol    = "6"
        source      = "<SbntDB1>.0/24"
        port_min    = "139"
        port_max    = "139"
        stateless   = "false"
      },
      {
        description = "SMB - From Sbnt-DB"
        protocol    = "6"
        source      = "<SbntDB1>.0/24"
        port_min    = "445"
        port_max    = "445"
        stateless   = "false"
      },
      {
        description = "HTTP Flow - From Sbnt-DB"
        protocol    = "6"
        source      = "<SbntDB1>.0/24"
        port_min    = "8081"
        port_max    = "8081"
        stateless   = "false"
      }

    ]
    egress = [
      {
        description = "Full OutBound IPv4"
        protocol    = "all"
        destination = "0.0.0.0/0"
        stateless   = "false"
      }
    ]
  },
  "nsgApp-Vivace" = {
    ingress = [
      {
        description = "RDP - From Sbnt-Public"
        protocol    = "6"
        source      = "<SbntPub1>.0/24"
        port_min    = "3389"
        port_max    = "3389"
        stateless   = "false"
      },
      {
        description = "HTTP - mPACSWeb - From Sbnt-Public"
        protocol    = "6"
        source      = "<SbntPub1>.0/24"
        port_min    = "80"
        port_max    = "81"
        stateless   = "false"
      },
      {
        description = "Editor - From Sbnt-Public"
        protocol    = "6"
        source      = "<SbntPub1>.0/24"
        port_min    = "84"
        port_max    = "84"
        stateless   = "false"
      },
      {
        description = "HTTPS - mPACSWeb, IDCE - From Sbnt-Public"
        protocol    = "6"
        source      = "<SbntPub1>.0/24"
        port_min    = "443"
        port_max    = "443"
        stateless   = "false"
      },
      {
        description = "WADO - From Sbnt-Public"
        protocol    = "6"
        source      = "<SbntPub1>.0/24"
        port_min    = "1000"
        port_max    = "1000"
        stateless   = "false"
      },
      {
        description = "License - From Sbnt-Public"
        protocol    = "6"
        source      = "<SbntPub1>.0/24"
        port_min    = "5001"
        port_max    = "5001"
        stateless   = "false"
      },
      {
        description = "Vivace Connect - From Sbnt-Public"
        protocol    = "6"
        source      = "<SbntPub1>.0/24"
        port_min    = "5555"
        port_max    = "5555"
        stateless   = "false"
      },
      {
        description = "Vivace Connect - From Sbnt-Public"
        protocol    = "6"
        source      = "<SbntPub1>.0/24"
        port_min    = "8042"
        port_max    = "8042"
        stateless   = "false"
      },
      {
        description = "Portal De Exames(ADM) - From Sbnt-Public"
        protocol    = "6"
        source      = "<SbntPub1>.0/24"
        port_min    = "8080"
        port_max    = "8080"
        stateless   = "false"
      },
      {
        description = "Router - From Sbnt-Public"
        protocol    = "6"
        source      = "<SbntPub1>.0/24"
        port_min    = "8091"
        port_max    = "8094"
        stateless   = "false"
      },
      {
        description = "Router - From Sbnt-Public"
        protocol    = "6"
        source      = "<SbntPub1>.0/24"
        port_min    = "431"
        port_max    = "433"
        stateless   = "false"
      },
      {
        description = "Router - From Sbnt-App"
        protocol    = "6"
        source      = "<SbntApp1>.0/24"
        port_min    = "139"
        port_max    = "139"
        stateless   = "false"
      },
      {
        description = "Router - From Sbnt-App"
        protocol    = "6"
        source      = "<SbntApp1>.0/24"
        port_min    = "445"
        port_max    = "445"
        stateless   = "false"
      },
      {
        description = "License - From Sbnt-App"
        protocol    = "6"
        source      = "<SbntApp1>.0/24"
        port_min    = "5001"
        port_max    = "5001"
        stateless   = "false"
      },
      {
        description = "NFS - From Sbnt-App"
        protocol    = "6"
        source      = "<SbntApp1>.0/24"
        port_min    = "111"
        port_max    = "111"
        stateless   = "false"
      },
      {
        description = "Router - From Sbnt-App"
        protocol    = "6"
        source      = "<SbntApp1>.0/24"
        port_min    = "8090"
        port_max    = "8094"
        stateless   = "false"
      }
    ]
    egress = [
      {
        description = "Full OutBound IPv4"
        protocol    = "all"
        destination = "0.0.0.0/0"
        stateless   = "false"
      }
    ]
  },
  "nsgApp-GlobalHealth" = {
      ingress = [
        {
          description = "Global Health"
          protocol    = "6"
          source      = "35.168.132.188/32"
          port_min    = "5443"
          port_max    = "5443"
          stateless   = "false"
        },
        {
          description = "Global Health"
          protocol    = "6"
          source      = "35.168.132.188/32"
          port_min    = "4443"
          port_max    = "4443"
          stateless   = "false"
        },
        {
          description = "Global Health"
          protocol    = "6"
          source      = "<SbntPub1>.0/24"
          port_min    = "5443"
          port_max    = "5443"
          stateless   = "false"
        },
        {
          description = "Global Health"
          protocol    = "6"
          source      = "<SbntPub1>.0/24"
          port_min    = "4443"
          port_max    = "4443"
          stateless   = "false"
        }
      ]
      egress = [
        {
          description = "Full OutBound IPv4"
          protocol    = "all"
          destination = "0.0.0.0/0"
          stateless   = "false"
        }
      ]
  },
  "nsg-WSGreen" = {
    ingress = [
      {
        description = "WEBSERVICE - GREEN - 01"
        protocol  = "6"
        source    = "177.36.11.9/32"
        port_min  = "2443"
        port_max  = "2443"
        stateless = "false"
      },
      {
        description = "WEBSERVICE - GREEN - 02"
        protocol  = "6"
        source    = "170.254.149.222/32"
        port_min  = "2443"
        port_max  = "2443"
        stateless = "false"
      },
      {
        description = "WEBSERVICE - GREEN - 03"
        protocol  = "6"
        source    = "177.69.49.49/32"
        port_min  = "2443"
        port_max  = "2443"
        stateless = "false"
      },
      {
        description = "WEBSERVICE - GREEN - 04"
        protocol  = "6"
        source    = "201.47.122.106/32"
        port_min  = "2443"
        port_max  = "2443"
        stateless = "false"
      },
      {
        description = "WEBSERVICE - GREEN - 05"
        protocol  = "6"
        source    = "129.213.208.48/32"
        port_min  = "2443"
        port_max  = "2443"
        stateless = "false"
      },
      {
        description = "WEBSERVICE - GREEN - 06"
        protocol  = "6"
        source    = "129.213.184.117/32"
        port_min  = "2443"
        port_max  = "2443"
        stateless = "false"
      },
      {
        description = "WEBSERVICE - GREEN - 07"
        protocol  = "6"
        source    = "129.159.51.33/32"
        port_min  = "2443"
        port_max  = "2443"
        stateless = "false"
      },
      {
        description = "WEBSERVICE - GREEN - 08"
        protocol  = "6"
        source    = "129.151.36.168/32"
        port_min  = "2443"
        port_max  = "2443"
        stateless = "false"
      },
      {
        description = "WEBSERVICE - GREEN - 09"
        protocol  = "6"
        source    = "129.151.34.218/32"
        port_min  = "2443"
        port_max  = "2443"
        stateless = "false"
      },
      {
        description = "WEBSERVICE - GREEN - 10"
        protocol  = "6"
        source    = "129.213.181.225/32"
        port_min  = "2443"
        port_max  = "2443"
        stateless = "false"
      },
	        {
        description = "WEBSERVICE - GREEN - 01"
        protocol  = "6"
        source    = "177.36.11.9/32"
        port_min  = "3443"
        port_max  = "3443"
        stateless = "false"
      },
      {
        description = "WEBSERVICE - GREEN - 02"
        protocol  = "6"
        source    = "170.254.149.222/32"
        port_min  = "3443"
        port_max  = "3443"
        stateless = "false"
      },
      {
        description = "WEBSERVICE - GREEN - 03"
        protocol  = "6"
        source    = "177.69.49.49/32"
        port_min  = "3443"
        port_max  = "3443"
        stateless = "false"
      },
      {
        description = "WEBSERVICE - GREEN - 04"
        protocol  = "6"
        source    = "201.47.122.106/32"
        port_min  = "3443"
        port_max  = "3443"
        stateless = "false"
      },
      {
        description = "WEBSERVICE - GREEN - 05"
        protocol  = "6"
        source    = "129.213.208.48/32"
        port_min  = "3443"
        port_max  = "3443"
        stateless = "false"
      },
      {
        description = "WEBSERVICE - GREEN - 06"
        protocol  = "6"
        source    = "129.213.184.117/32"
        port_min  = "3443"
        port_max  = "3443"
        stateless = "false"
      },
      {
        description = "WEBSERVICE - GREEN - 07"
        protocol  = "6"
        source    = "129.159.51.33/32"
        port_min  = "3443"
        port_max  = "3443"
        stateless = "false"
      },
      {
        description = "WEBSERVICE - GREEN - 08"
        protocol  = "6"
        source    = "129.151.36.168/32"
        port_min  = "3443"
        port_max  = "3443"
        stateless = "false"
      },
      {
        description = "WEBSERVICE - GREEN - 09"
        protocol  = "6"
        source    = "129.151.34.218/32"
        port_min  = "3443"
        port_max  = "3443"
        stateless = "false"
      },
      {
        description = "WEBSERVICE - GREEN - 10"
        protocol  = "6"
        source    = "129.213.181.225/32"
        port_min  = "3443"
        port_max  = "3443"
        stateless = "false"
      }
    ]
    egress = [
      {
        description = "Full OutBound IPv4"
        protocol    = "all"
        destination = "0.0.0.0/0"
        stateless   = "false"
      }
    ]
  },
  "nsgLB-Main" = {
    ingress = [
      {
        description = "All In From VNC"
        protocol    = "all"
        source      = "<SbntPub1>.0/22"
        stateless   = "false"
      }
    ]
    egress = [
      {
        description = "Full OutBound IPv4"
        protocol    = "all"
        destination = "0.0.0.0/0"
        stateless   = "false"
      }
    ]
  },
  "nsgLB-Public" = {
    ingress = [
      {
        description = "Web-HTTP - From www"
        protocol    = "6"
        source      = "0.0.0.0/0"
        port_min    = "80"
        port_max    = "85"
        stateless   = "false"
      },
      {
        description = "Web-HTTPS - From www"
        protocol    = "6"
        source      = "0.0.0.0/0"
        port_min    = "443"
        port_max    = "443"
        stateless   = "false"
      },
      {
        description = "Vivace - Portal De Exames - from www"
        protocol    = "6"
        source      = "0.0.0.0/0"
        port_min    = "431"
        port_max    = "433"
        stateless   = "false"
      },
      {
        description = "Vivace - WADO - From Sbnt-Public"
        protocol    = "6"
        source      = "0.0.0.0/0"
        port_min    = "1000"
        port_max    = "1000"
        stateless   = "false"
      },
      {
         description = "Vivace - Connect - From Sbnt-Public"
        protocol    = "6"
        source      = "0.0.0.0/0"
        port_min    = "5555"
        port_max    = "5555"
        stateless   = "false"
      },
      {
        description = "Vivace - Connect - From Sbnt-Public"
        protocol    = "6"
        source      = "0.0.0.0/0"
        port_min    = "8042"
        port_max    = "8042"
        stateless   = "false"
      },
      {
        description = "Vivace - NGINX - From Sbnt-Public"
        protocol    = "6"
        source      = "0.0.0.0/0"
        port_min    = "11000"
        port_max    = "11000"
        stateless   = "false"
      },
      {
        description = "Vivace - API LAUDO Remoto - From Sbnt-Public"
        protocol    = "6"
        source      = "0.0.0.0/0"
        port_min    = "11200"
        port_max    = "11204"
        stateless   = "false"
      },
      {
        description = "Vivace - API RIS Admin - From Sbnt-Public"
        protocol    = "6"
        source      = "0.0.0.0/0"
        port_min    = "11300"
        port_max    = "11300"
        stateless   = "false"
      }
    ]
    egress = [
      {
        description = "Full OutBound IPv4"
        protocol    = "all"
        destination = "0.0.0.0/0"
        stateless   = "false"
      }
    ]
  },
  "nsgCustomer-Public" = {
    ingress = [
      {
        description = "HTTP - From Unidade Cliente"
        protocol    = "6"
        source      = "192.168.0.0/24"
        port_min    = "80"
        port_max    = "85"
        stateless   = "false"
      },
      {
        description = "HTTPS - From Unidade Cliente"
        protocol    = "6"
        source      = "192.168.0.0/24"
        port_min    = "443"
        port_max    = "443"
        stateless   = "false"
      }
    ]
    egress = [
      {
        description = "Full OutBound IPv4"
        protocol    = "all"
        destination = "0.0.0.0/0"
        stateless   = "false"
      }
    ]
  },
  "nsgCustomer-DB" = {
    ingress = [
      {
        description = "ORACLE - From Unidade Cliente"
        protocol    = "6"
        source      = "192.168.0.0/24"
        port_min    = "1521"
        port_max    = "1521"
        stateless   = "false"
      }
    ]
    egress = [
      {
        description = "Full OutBound IPv4"
        protocol    = "all"
        destination = "0.0.0.0/0"
        stateless   = "false"
      }
    ]
  }
}


# ROUTE-TABLE
route_tables = {
  "privateRouteTable" = {
    route_rules = [
      {
        description         = "Route to NAT Gateway"
        destination         = "0.0.0.0/0"
        network_entity_name = "defaultNatGateway"
        target_type         = "ngw"
      },
      {
        description         = "Route to SGW"
        destination         = "0.0.0.0/0"
        network_entity_name = "defaultServiceGateway"
        target_type         = "sgw"
      },
      {
        description         = "vcnAdministration"
        destination         = "10.3.0.0/24"
        network_entity_name = "LPG-CLIENT-ADM"
        target_type         = "lpg"
      #},
      #{
      #  description         = "Customer Client to DRG"
      #  destination         = "192.168.0.0/24"
      #  network_entity_name = "DRG-MVCodCliVCN"
      #  target_type         = "drg"
      }
    ]
  },
  "publicRouteTable" = {
    route_rules = [
      {
        description         = "Route to Internet Gateway"
        destination         = "0.0.0.0/0"
        network_entity_name = "defaultInternetGateway"
        target_type         = "igw"
      },
      {
        description         = "vcnAdministration"
        destination         = "10.3.0.0/24"
        network_entity_name = "LPG-CLIENT-ADM"
        target_type         = "lpg"
      #},
      #{
      #  description         = "Customer Client to DRG"
      #  destination         = "192.168.0.0/24"
      #  network_entity_name = "DRG-MVCodCliVCN"
      #  target_type         = "drg"
      }
    ]
  }
}


# LOAD-BALANCER-MAIN
load_balancer_db = {
  #display_name         = "MAIN-CodCli"
  #private              = false
  #subnet_name          = "PUBLICCodCli"
  #security_group_names = ["nsgLB-Main"]
  #max_mbps             = 10
  #min_mbps             = 10
  #additional_listeners = [
    #{
    #  name                    = "listerner-80"
    #  port                    = 80
    #  protocol                = "HTTP"
    #  idle_timeout_in_seconds = 70
    #  redirect_rules = [
    #    {
    #      name = "redirectToHttps"
    #      rules = [
    #        {
    #          # PATH or SOURCE_IP_ADDRESS
    #          source_type  = "PATH"
    #          source_value = "/"
    #          # EXACT_MATCH, FORCE_LONGEST_PREFIX_MATCH, PREFIX_MATCH e SUFFIX_MATCH
    #          source_operator = "PREFIX_MATCH"
    #          # "{host}"
    #          redirect_host = "{host}"
    #          # "{path}"
    #          redirect_path = "{path}"
    #          # "{port}"
    #          redirect_port = "443"
    #          # "{protocol}"
    #          redirect_protocol = "HTTPS"
    #          # "{query}"
    #          redirect_query = "{query}"
    #          # 301, 302, 303, 307, 308
    #          response_code = 301
    #        }
    #      ]
    #    },
    #  ]
    #  backend_set = {
    #    name                           = "backend-set-1"
    #    policy                         = "LEAST_CONNECTIONS"
    #    health_check_url               = "/health"
    #    health_check_port              = 80
    #    health_check_protocol          = "HTTP"
    #    health_check_return_code       = 200
    #    health_check_interval_ms       = 1000
    #    health_check_timeout_in_millis = 3
    #    health_check_retries           = 3
    #    health_check_res_body_regex    = ""
    #    backends = [
    #      {
    #        ip_address = "10.62.1.1"
    #        port       = 80
    #      }
    #    ]
    #  }
    #}
  #]
}


# LOAD-BALANCER
load_balancers = {
  #PUBLIC-CodCli-A = {
  #  subnet_name                 = "PUBLICCodCli"
  #  private                     = false
  #  security_group_names        = ["nsgLB-Public"]
  #  max_mbps                    = 10
  #  min_mbps                    = 10
  #  public_ip_name              = "LB-002"
  #  #ssl_cert_name               = ""
  #  #ssl_cert_ca_certificate     = ""
  #  #ssl_cert_passphrase         = ""
  #  #ssl_cert_private_key        = ""
  #  #ssl_cert_public_certificate = ""
  #  hostnames = [
  #    {
  #      name     = "teste"
  #      hostname = "teste.com.br",
  #    },
  #    {
  #      name     = "teste2"
  #      hostname = "teste2.com.br",
  #    }
  #  ]
  #  listeners = [
  #    {
  #      name                    = "listerner"
  #      port                    = 80
  #      protocol                = "HTTP"
  #      idle_timeout_in_seconds = 70
  #      hostname_names          = ["teste", "teste2"]
  #      redirect_rules = [
  #        {
  #          name = "redirectToHttps"
  #          rules = [
  #            {
  #              # PATH or SOURCE_IP_ADDRESS
  #              source_type  = "PATH"
  #              source_value = "/"
  #              # EXACT_MATCH, FORCE_LONGEST_PREFIX_MATCH, PREFIX_MATCH e SUFFIX_MATCH
  #              source_operator = "PREFIX_MATCH"
  #              # "{host}"
  #              redirect_host = "{host}"
  #              # "{path}"
  #              redirect_path = "{path}"
  #              # "{port}"
  #              redirect_port = "443"
  #              # "{protocol}"
  #              redirect_protocol = "HTTPS"
  #              # "{query}"
  #              redirect_query = "{query}"
  #              # 301, 302, 303, 307, 308
  #              response_code = 301
  #            }
  #          ]
  #        },
  #        {
  #          name = "redirectToHttps2"
  #          rules = [
  #            {
  #              # PATH or SOURCE_IP_ADDRESS
  #              source_type  = "PATH"
  #              source_value = "/"
  #              # EXACT_MATCH, FORCE_LONGEST_PREFIX_MATCH, PREFIX_MATCH e SUFFIX_MATCH
  #              source_operator = "PREFIX_MATCH"
  #              # "{host}"
  #              redirect_host = "{host}"
  #              # "{path}"
  #              redirect_path = "{path}"
  #              # "{port}"
  #              redirect_port = "443"
  #              # "{protocol}"
  #              redirect_protocol = "HTTPS"
  #              # "{query}"
  #              redirect_query = "{query}"
  #              # 301, 302, 303, 307, 308
  #              response_code = 301
  #            }
  #          ]
  #        },
  #      ]
  #      backend_set = {
  #        name                           = "backend-set-1"
  #        policy                         = "LEAST_CONNECTIONS"
  #        health_check_url               = "/health"
  #        health_check_port              = 80
  #        health_check_protocol          = "HTTP"
  #        health_check_return_code       = 200
  #        health_check_interval_ms       = 1000
  #        health_check_timeout_in_millis = 3
  #        health_check_retries           = 3
  #        health_check_res_body_regex    = ""
  #        backends = [
  #          {
  #            ip_address = "10.62.1.1"
  #            port       = 80
  #          }
  #        ]
  #        routing_policies = [
  #          {
  #            name = "teste1"
  #            rules = [
  #              {
  #                name      = "testerule"
  #                condition = "all(http.request.url.path eq (i '/teste'))"
  #              }
  #            ]
  #          }
  #        ]
  #      }
  #    },
  #    {
  #      name                    = "lstnr_https"
  #      port                    = 443
  #      protocol                = "HTTP"
  #      idle_timeout_in_seconds = 120
  #      certificate_ids         = ["ocid1.certificate.oc1.sa-saopaulo-1.amaaaaaalmjo46aap2v4kfgw43e2gf5aauzwwd66hmcuqlgc4bcrkrgek2ta"]
  #      hostname_names          = ["teste", "teste2"]
  #      redirect_rules          = []
  #      backend_set             = {
  #        name                           = "backend-set-2"
  #        policy                         = "LEAST_CONNECTIONS"
  #        health_check_url               = "/health"
  #        health_check_port              = 80
  #        health_check_protocol          = "HTTP"
  #        health_check_return_code       = 200
  #        health_check_interval_ms       = 1000
  #        health_check_timeout_in_millis = 3
  #        health_check_retries           = 3
  #        health_check_res_body_regex    = ""
  #        backends = [
  #          {
  #            ip_address = "10.62.1.1"
  #            port       = 80
  #          },
  #          {
  #            ip_address = "10.62.1.2"
  #            port       = 80
  #          },
  #          {
  #            ip_address = "10.62.1.3"
  #            port       = 80
  #          }
  #        ]
  #        routing_policies = []
  #      }
  #    }
  #  ]
  #}
}


# FILE STORAGE
file_storage_system = {
  # name = "FileSystem"
  # mount_targets = [
  #   {
  #     display_name         = "databases"
  #     hostname_label       = "databases"
  #     subnet_name          = "DB3323"
  #     ip_address           = "10.97.162.252"
  #     security_group_names = []
  #   }
  # ]
  # export_sets = [
  #   {
  #     display_name      = "databases"
  #     mount_target_name = "databases"
  #     max_fs_stat_bytes = null
  #     max_fs_stat_files = null
  #   }
  # ]
  # storage_exports = [
  #   {
  #     export_set_name = "databases"
  #     path            = "/databases"
  #     export_options = {
  #       source                         = "0.0.0.0/0"
  #       access                         = "READ_WRITE"
  #       identity_squash                = "NONE"
  #       anonymous_uid                  = null
  #       anonymous_gid                  = null
  #       require_privileged_source_port = true
  #     }
  #   }
  # ]
}


# WAF
# https://docs.oracle.com/en-us/iaas/tools/terraform-provider-oci/5.10/docs/r/waf_web_app_firewall_policy.html
waf = {
  # name               = "waf"
  # load_balancer_name = "LB-001"
  # actions = [
  #   {
  #     type = "ALLOW"
  #     name = "defaultAction"
  #   },
  #   {
  #     type = "RETURN_HTTP_RESPONSE"
  #     name = "return401Response"
  #     code = 401
  #     body = {
  #       type = "STATIC_TEXT"
  #       text = "{\n\"code\": 401,\n\"message\":\"Unauthorised\"\n}"
  #     }
  #     headers = [
  #       {
  #         name  = "Header1"
  #         value = "Value1"
  #       }
  #     ]
  #   }
  # ]
  # request_accesss_control = {
  #   default_action_name = "defaultAction"
  #   rules = [
  #     {
  #       type               = "ACCESS_CONTROL"
  #       name               = "requestAccessRule"
  #       action_name        = "return401Response"
  #       condition          = "i_contains(keys(http.request.headers), 'Header1')"
  #       condition_language = "JMESPATH"
  #     }
  #   ]
  # }
  # response_access_control = {
  #   rules = [
  #     {
  #       type               = "ACCESS_CONTROL"
  #       name               = "requestAccessRule"
  #       action_name        = "return401Response"
  #       condition          = "i_contains(keys(http.request.headers), 'Header1')"
  #       condition_language = "JMESPATH"
  #     }
  #   ]
  # }
  # request_rate_limiting = {
  #   rules = [
  #     {
  #       type               = "REQUEST_RATE_LIMITING"
  #       name               = "requestRateLimitingRule"
  #       action_name        = "return401Response"
  #       condition          = "i_contains(keys(http.request.headers), 'Header1')"
  #       condition_language = "JMESPATH"
  #       configurations = {
  #         period_in_seconds          = 100
  #         requests_limit             = 10
  #         action_duration_in_seconds = 10
  #       }
  #     }
  #   ]
  # }
  # request_protection = {
  #   body_inspection_size_limit_exceeded_action_name = "return401Response"
  #   body_inspection_size_limit_in_bytes             = 8192
  #   rules = [
  #     {
  #       type                       = "PROTECTION"
  #       name                       = "requestProtectionRule"
  #       action_name                = "return401Response"
  #       is_body_inspection_enabled = true
  #       condition                  = ""
  #       condition_language         = ""
  #       protection_capabilities = [
  #         {
  #           key     = "9300000"
  #           version = 1
  #         }
  #       ]
  #     }
  #   ]
  # }
}


# FASTCONNECT
# https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_virtual_circuit
fast_connect = {
  # PRIVATE OR PUBLIC
  # type                       = "PRIVATE"
  # name                       = "fast_connect"
  # bandwidth_shape_name       = "10 Gbps"
  # drg_name                   = "DRG-MV3323VCN"
  # provider_service_id        = ""
  # provider_service_key_name  = ""
  # bgp_admin_state            = "ENABLED"
  # customer_bgp_peering_ip    = "10.0.0.18/31"
  # oracle_bgp_peering_ip      = "10.0.0.19/31"
  # customer_asn               = 12355
  # ip_mtu                     = 1500
  # is_bfd_enabled             = true
  # circuit_region             = ""
  # public_prefixes_cidr_block = ""
}
