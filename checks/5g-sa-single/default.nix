{
  self,
  pkgs,
  lib,
  ...
}:
{
  name = "5g-sa-single";

  nodes.machine = {
    imports = [ self.nixosModules.default ];
    networking.useDHCP = false;
    services.open5gs = {
      enable = true;
      amf.enable = true;
      scp.enable = true;
      nrf.enable = true;
      ausf.enable = true;
      smf.enable = true;
      udm.enable = true;
      udr.enable = true;
      upf.enable = true;
    };

    # TODO register UE using mongodb init
    systemd.services = {
      nr-gnb =
        let
          gnbConf = pkgs.writeText "gnb.conf" ''
            mcc: '999'          # Mobile Country Code value
            mnc: '70'           # Mobile Network Code value (2 or 3 digits)

            nci: '0x000000010'  # NR Cell Identity (36-bit)
            idLength: 32        # NR gNB ID length in bits [22...32]
            tac: 1              # Tracking Area Code

            linkIp: 127.0.0.1   # gNB's local IP address for Radio Link Simulation (Usually same with local IP)
            ngapIp: 127.0.0.1   # gNB's local IP address for N2 Interface (Usually same with local IP)
            gtpIp: 127.0.0.1    # gNB's local IP address for N3 Interface (Usually same with local IP)

            # List of AMF address information
            amfConfigs:
              - address: 127.0.0.5
                port: 38412

            # List of supported S-NSSAIs by this gNB
            slices:
              - sst: 1

            # Indicates whether or not SCTP stream number errors should be ignored.
            ignoreStreamIds: true

            # Cell access type. When set to one of the satellite types (nr-leo, nr-meo,
            # nr-geo, nr-othersat), the gNB attaches the NR-NTN TAI Information extension
            # to every UserLocationInformationNR it sends to the AMF. Defaults to "nr".
            cellAccessType: nr
          '';
        in
        {
          description = "UERANSIM gNodeB";
          after = [ "open5gs-amf.service" ];
          wantedBy = [ "multi-user.target" ];
          serviceConfig = {
            ExecStart = "${lib.getExe' pkgs.ueransim "nr-gnb"} -c ${gnbConf}";
            Restart = "always";
            RestartSec = 2;
            RestartPreventExitStatus = 1;
          };
        };
      nr-ue =
        let
          ueConf = pkgs.writeText "ue.conf" ''
            # IMSI number of the UE. IMSI = [MCC|MNC|MSISDN] (In total 15 digits)
            supi: 'imsi-999700000000001'
            # Mobile Country Code value of HPLMN
            mcc: '999'
            # Mobile Network Code value of HPLMN (2 or 3 digits)
            mnc: '70'
            # SUCI Protection Scheme : 0 for Null-scheme, 1 for Profile A and 2 for Profile B
            protectionScheme: 0
            # Home Network Public Key for protecting with SUCI Profile A
            homeNetworkPublicKey: '5a8d38864820197c3394b92613b20b91633cbd897119273bf8e4a6f4eec0a650'
            # Home Network Public Key ID for protecting with SUCI Profile A
            homeNetworkPublicKeyId: 1
            # Routing Indicator
            routingIndicator: '0000'

            # Permanent subscription key
            key: '465B5CE8B199B49FAA5F0A2EE238A6BC'
            # Operator code (OP or OPC) of the UE
            op: 'E8ED289DEBA952E4283B54E88E6183CA'
            # This value specifies the OP type and it can be either 'OP' or 'OPC'
            opType: 'OPC'
            # Authentication Management Field (AMF) value
            amf: '8000'
            # IMEI number of the device. It is used if no SUPI is provided
            imei: '356938035643803'
            # IMEISV number of the device. It is used if no SUPI and IMEI is provided
            imeiSv: '4370816125816151'

            # Network mask used for the UE's TUN interface to define the subnet size
            tunNetmask: '255.255.255.0'

            # Create the UE TUN interface inside a dedicated Linux network namespace.
            useNamespace: false
            # Optional prefix used when deriving the namespace name.
            nsNamePrefix: 'ueransim'

            # List of gNB IP addresses for Radio Link Simulation
            gnbSearchList:
              - 127.0.0.1

            # UAC Access Identities Configuration
            uacAic:
              mps: false
              mcs: false

            # UAC Access Control Class
            uacAcc:
              normalClass: 0
              class11: false
              class12: false
              class13: false
              class14: false
              class15: false

            # Initial PDU sessions to be established
            sessions:
              - type: 'IPv4'
                apn: 'internet'
                slice:
                  sst: 1

            # Configured NSSAI for this UE by HPLMN
            configured-nssai:
              - sst: 1

            # Default Configured NSSAI for this UE
            default-nssai:
              - sst: 1
                sd: 1

            # Supported integrity algorithms by this UE
            integrity:
              IA1: true
              IA2: true
              IA3: true

            # Supported encryption algorithms by this UE
            ciphering:
              EA1: true
              EA2: true
              EA3: true

            # Integrity protection maximum data rate for user plane
            integrityMaxRate:
              uplink: 'full'
              downlink: 'full'
          '';
        in
        {
          description = "UERANSIM User Equipment";
          after = [ "nr-gnb.service" ];
          wantedBy = [ "multi-user.target" ];
          serviceConfig = {
            ExecStart = "${lib.getExe' pkgs.ueransim "nr-ue"} -c ${ueConf}";
            Restart = "always";
            RestartSec = 2;
            RestartPreventExitStatus = 1;
          };
        };
    };
  };

  testScript =
    { ... }:
    /* python */ ''
      with subtest("ensure mongodb open5gs database is configured"):
        machine.wait_for_unit("mongodb.service")
        for collection in ["users", "sessions", "subscribers"]:
          machine.succeed(f"${lib.getExe pkgs.mongosh} --quiet open5gs --eval 'print(db.getCollectionNames().includes(\"{collection}\"))' | grep true")

      with subtest("ensure open5gs core network is up and running"):
        machine.wait_for_unit("open5gs-amfd.service")
        machine.wait_for_unit("open5gs-scpd.service")
        machine.wait_for_unit("open5gs-nrfd.service")
        machine.wait_for_unit("open5gs-ausfd.service")
        # TODO
        #machine.wait_for_unit("open5gs-smf.service")
        #machine.wait_for_unit("open5gs-udm.service")
        #machine.wait_for_unit("open5gs-udr.service")
        #machine.wait_for_unit("open5gs-upf.service")

      with subtest("ensure gNodeB is registered"):
        machine.wait_for_unit("nr-gnb.service")

      with subtest("ensure user equipment is connected"):
        machine.wait_for_unit("nr-ue.service")

      print(machine.succeed("ss -tlupn"))
    '';
}
