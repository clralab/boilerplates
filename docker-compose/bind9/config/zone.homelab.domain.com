; example zone file for catching all subdomains and redirecting to traefik
$TTL 2d    ; default TTL for zone
$ORIGIN homelab.domain.com. ; base domain-name
; Start of Authority RR defining the key characteristics of the zone (domain)
@			IN		SOA		ns1.homelab.domain.com. homelab.outlook.com. (
                        2023120200 ; serial number
                        12h        ; refresh
                        15m        ; update retry
                        3w         ; expiry
                        2h         ; minimum
                        )
; name server RR for the domain
			IN		NS	ns1.homelab.domain.com.
; return the IPv4 address x.x.x.x from this zone file
ns1			IN		A	x.x.x.x
; add a catch all to redirect all traffic to traefik
*			  IN		A	x.x.x.y