current_dir = File.dirname(__FILE__)
log_level                :info
log_location             STDOUT
node_name                "nay"
client_key               "#{current_dir}/nay.pem"
validation_client_name   "adobecloudops-validator"
validation_key           "#{current_dir}/adobecloudops-validator.pem"
chef_server_url          "https://api.opscode.com/organizations/adobecloudops"
cache_type               'BasicFile'
cache_options( :path => "#{ENV['HOME']}/.chef/checksums" )
cookbook_path            ["#{current_dir}/../cookbooks"]
