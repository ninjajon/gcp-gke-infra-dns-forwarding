# gcp-gke-infra-dns-forwarding

## Setup
### Windows Server
- RDP on it and make sure to set DNS configs to its own ip addresss

### Nodes
- SSH on one of them and install dig: 
```
sudo apt update
sudo apt install dnsutils
```

## Test with dig
- Test the DNS resolution using the following command:
```
dig test1.jo.com
```