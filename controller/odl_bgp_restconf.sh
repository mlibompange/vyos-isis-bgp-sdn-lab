#!/usr/bin/env bash
# Configures OpenDaylight (BGPCEP) as a passive iBGP peer of R1 over RESTCONF.
# Usage: ODL_AUTH=user:password ./odl_bgp_restconf.sh
set -u
O=${ODL_URL:-http://localhost:8181}/rests/data
A="${ODL_AUTH:?Set ODL_AUTH=user:password for the RESTCONF API}"
X='Content-Type: application/yang-data+xml'
P=openconfig-network-instance:network-instances/network-instance=global-bgp
curl -s -o /dev/null -w "instance %{http_code}\n" -u $A -X POST -H "$X" -d '<protocol xmlns="http://openconfig.net/yang/network-instance"><name>bgp-to-r1</name><identifier xmlns:x="http://openconfig.net/yang/policy-types">x:BGP</identifier><bgp xmlns="urn:opendaylight:params:xml:ns:yang:bgp:openconfig-extensions"><global><config><router-id>192.168.29.10</router-id><as>65002</as></config></global></bgp></protocol>' $O/$P/protocols
curl -s -o /dev/null -w "acceptor %{http_code}\n" -u $A -X PUT -H "$X" -d '<bgp-peer-acceptor-config xmlns="urn:opendaylight:params:xml:ns:yang:odl-bgp-peer-acceptor-config"><config-name>default</config-name><binding-address>0.0.0.0</binding-address><binding-port>1790</binding-port></bgp-peer-acceptor-config>' $O/odl-bgp-peer-acceptor-config:bgp-peer-acceptor-config=default
curl -s -o /dev/null -w "neighbor %{http_code}\n" -u $A -X POST -H "$X" -d '<neighbor xmlns="urn:opendaylight:params:xml:ns:yang:bgp:openconfig-extensions"><neighbor-address>192.168.29.11</neighbor-address><timers><config><hold-time>90</hold-time><connect-retry>10</connect-retry></config></timers><transport><config><remote-port>1790</remote-port><passive-mode>true</passive-mode></config></transport><config><peer-type>INTERNAL</peer-type><peer-as>65002</peer-as></config><afi-safis><afi-safi><afi-safi-name xmlns:x="http://openconfig.net/yang/bgp-types">x:IPV4-UNICAST</afi-safi-name><config><afi-safi-name xmlns:x="http://openconfig.net/yang/bgp-types">x:IPV4-UNICAST</afi-safi-name><enabled>true</enabled></config></afi-safi></afi-safis></neighbor>' $O/$P/openconfig-network-instance:protocols/protocol=openconfig-policy-types:BGP,bgp-to-r1/bgp-openconfig-extensions:bgp/neighbors
