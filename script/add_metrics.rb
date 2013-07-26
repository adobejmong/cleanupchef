#this script detect terminated nodes (nodes with terminated AWS instances) on the Chef server
#and offers the possibility to delete them

require 'rubygems'
require 'chef'
require 'aws'
require 'aws-sdk'
require './functions.rb'

puts "Started"

#VARIABLE
accessvalues = ""
secretvalues = ""
array = [] #array of hash to store{access_key,secret_key}
number_accounts = 0 #number of AWS accounts
ec2_ids = [] #running instances array
number_of_running_instances=0 #number of running instances
number_of_terminated_nodes=0 #number of terminated instances
number_of_registered_nodes=0 #number of registered instances
number_of_subscribed_nodes= get_string_from_file($initial_config_file,'chef_subscribed_nodes = ')
#configuration parameters can be modified in $initial_config_file (global variable)
bucket_name= get_string_from_file($initial_config_file,'s3_bucket_name = ')
aws_accounts_file = get_string_from_file($initial_config_file,'aws_accounts_file = ')
chef_config_file = get_string_from_file($initial_config_file,'chef_config_file = ')
chef_c_private_key_file = get_string_from_file($initial_config_file,'chef_private_key_file = ')

write_to_log(":starting\n") #write to log file

#GET CONFIGURATION FILES
#S3 bucket Access and Secret Keys
s3_access_key,s3_secret_key=get_aws_credentials($initial_config_file,'s3_accesskey = ','s3_secretkey = ')
#Settings File
settings_file = get_file_from_bucket(s3_access_key,s3_secret_key,bucket_name,'settings.txt')
#AWS Account Credentials
aws_accounts_keys_file = get_file_from_bucket(s3_access_key,s3_secret_key,bucket_name,aws_accounts_file)
#Chef Configuration File
chef_knife_file = get_file_from_bucket(s3_access_key,s3_secret_key,bucket_name,chef_config_file)
chef_private_key_file=get_file_from_bucket(s3_access_key,s3_secret_key,bucket_name,chef_c_private_key_file)
write_to_log("configuration files\n")

#Get AWS Accounts Access Key and Secret Key
lines =open_file("../localfiles/#{aws_accounts_keys_file}")
lines.gsub!(/\r\n?/, "\n")
lines.each_line do |line|
  if ( line =~ /access/ ) # get access key
    accessvalues = ""
    accessvalues =line.gsub!(/(access = )|(\n)/,"")
  end
  if ( line =~ /secret/ )  # get secret key
    secretvalues = ""
    secretvalues =line.gsub!(/(secret = )|(\n)/,"")
  end
  if (accessvalues != "") && (secretvalues != "") #we got the first account keys
    number_accounts += 1
    hash = Hash.new #initialize the hash
hash = { :access_key => accessvalues, :secret_key => secretvalues}
    array.push(hash) #array of hashes(access key  and secret key)
    accessvalues = ""
    secretvalues = ""
  end
end
write_to_log("number of accounts: #{number_accounts}\n")

# Load Chef Server Configuration file
Chef::Config.from_file(chef_knife_file)
#list all used AWS region - listing all here
#TODO get all regions automatically
aws_regions = ["us-east-1", "us-west-1", "us-west-2", "eu-west-1", "ap-northeast-1", "ap-southeast-1", "ap-southeast-2", "sa-east-1"]
all_running_ec2_ids =[]

for account in 0..number_accounts-1
  #TODO get account full name instead of displaying access key and secret key
  write_to_log("Checking account: #{account+1}\n")
  access_key = array[account][:access_key]
  secret_key = array[account][:secret_key]
  aws_regions.each do |aws_region|
    ec2_ids = [] #initialise array of instances
    write_to_log("For region: #{aws_region}\n")
aws_account = Aws::Ec2.new( access_key, secret_key, :region => aws_region)
    # Get running ec2 instance ids
    ec2_id = aws_account.describe_instances.reject{|i| i[:aws_state] == "terminated"}.collect{|i| i[:aws_instance_id]}
    ec2_ids = ec2_ids + ec2_id
    write_to_log("Running ec2 instances IDs\n")
    all_running_ec2_ids = all_running_ec2_ids + ec2_ids
    number_of_running_instances=number_of_running_instances+ec2_ids.length
    write_to_log("Running ec2 instances IDs: #{number_of_running_instances}\n")
    write_to_log("Running EC2 Instances: " + ec2_ids.join("")+ "\n")

   end
end

# Get list of terminated nodes
terminated_nodes = []
write_to_log ("writing to file node_to_delete\n")
file=File.new('../localfiles/nodes_to_delete---' + Time.now.strftime("%m-%d-%Y-%H-%m")+'.txt','w')
file.write "Instance Name; Instance ID, AWS Region\n"
#number of registered ec2 instances
nodes = Chef::Search::Query.new.search(:node, "ec2_instance_id:i-*").first rescue []
nodes.each do |node|
  number_of_registered_nodes = number_of_registered_nodes +1
if !all_running_ec2_ids.include? node["ec2"]["instance_id"] #if running instance not in registered instances
    file.write node.name + ";"
    file.write node.ec2.instance_id + ";\n"
    #file.write aws_region + ";\n"
    terminated_nodes << node.name
    number_of_terminated_nodes=terminated_nodes.length #number of terminated instances
 end
end

write_to_log("number of TERMINATED: #{number_of_terminated_nodes}\n")

#Write values to $cw_metrics_values_file
file_cw=File.new($cw_metrics_values_file,'w')
file_cw.write("nodes_subscribed = #{number_of_subscribed_nodes}\n")
file_cw.write("nodes_registered = #{number_of_registered_nodes}\n")
file_cw.write("nodes_active = #{number_of_registered_nodes-number_of_terminated_nodes}\n")


#TODO:delete nodes script
##TODO:Using Cross Delegation

puts "Ended"
