0,/^\}/s/^\}/\}\nfilter \{ \
     if \[data\]\[alert\]\[signature_id\] \{ \
        translate \{ \
          override => true \
          exact => true \
          field => "[data][alert][signature_id]" \
          destination => "[rule][pci_dss]" \
          dictionary_path => "\/etc\/logstash\/config\/pci_3.2.yaml" \
        } \
     } \
}/

