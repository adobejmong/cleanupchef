- The script 'chefcleanup.rb' detects terminated nodes and offers the possibility to delete them from the Chef server
- The script 'add_metrics.rb' publishes metric data points into Amazon CloudWatch.

####FOLDER HIERARCHY:

- script/chefcleanup.rb
- script/add_metrics.rb
- script/functions.rb
- localfiles/initial_config.txt
- output/

####BEFORE YOU START

Make sure you have the following dependencies:

- [1] Chef Configuration
   - Get your chef-repo-specific configuration details for Knife (e.g., knife.rb)
   - Get the user Private Key file (.pem)
   - Get the number of subscribed nodes (nodes allowed by Opscode)
- [2] AWS accounts Credentials 
   - Get your AWS Accounts Credentials (Access Key and Secret Key) of IAM users that are authorized to run 'ec2-describe-instances'
   - Place them in a file (e.g, credentials.txt) as shown below

```
#AWS Account Number 1
access = XXXXXXXXXXXXXXX
secret = XXXXXXXXXXXXXXXXXXXXX
#AWS Account Number 2
access = XXXXXXXXXXXXXXX
secret = XXXXXXXXXXXXXXXXXXXXX
#AWS Account Number n
access = XXXXXXXXXXXXXXX
secret = XXXXXXXXXXXXXXXXXXXXX
```
- [3] S3 Bucket
   - Create an S3 Bucket and get its name
   - Create an IAM user that can access this bucket
   - Get the IAM user credentials (Access Key and Secret Key)
- [4] Cloud Watch
    - Create an IAM user that can run Cloud Watch commands
    - Choose a namespace and metrics names
    - Determine your account Cloud Watch region (i.e, us-east-1, us-west-1...)
    

####COPY FILES TO S3 BUCKET (from Step [3])

- Chef configuration file (from Step [1])
- The user 's private key (from Step [1])
- The user private key (from Step [1])
- AWS accounts' credentials file (from Step [3])
    
####EDIT CONFIGURATION FILE

Before you run the script:
- Create 'initial_config.txt' file from the template below under /localfiles
- Edit the fields by replacing 'from step (x)' with the corresponding values from the section above (BEFORE YOU START). 
- !!!!!Please make sure to keep the space before and after the '=' sign.

```
################Template###########################
#Main Credentials: S3 bucket Access and Secret Keys
s3_accesskey = from step [3]
s3_secretkey = from step [3]
#Bucket name
s3_bucket_name = from step [3]
#AWS Accounts Credentials File
aws_accounts_file = from step [2]
#Chef Config file (knife file)
chef_config_file = from step [1]
#Number of nodes subscribed
chef_subscribed_nodes = from step [1]
#CloudWatch IAM User Credentials
cw_access_key = from step [4]
cw_secret_key = from step [4]
#Cloudwatch Metrics
cw_region = from step [4]
namespace = from step [4]
metric1 = from step [4]
metric2 = from step [4]
metric3 = from step [4]
```

####RUN THE SCRIPT

ruby cleanupchef.rb


####RUN CLOUDWATCH SCRIPT
ruby add_metrics.rb

####OUTPUT

- Log file: 'logs.txt' (under localfiles/)
- Cloud Watch values: 'cw_metrics.txt' (under output/)
- Terminated instances: 'nodes_to_delete---mm-dd-yyyy-hh.txt' (under output/)
- Script to run to delete nodes from the chef server ( #####TODO###)
- 
####RUN DELETE SCRIPT

- Append this to 'chefcleanup.rb' script

```
###gets the name of the terminated instances on chef 
###and delete them
terminated_nodes.each do |terminated_node|
  terminated_node_on_chef = Chef::ApiClient.load(terminated_node.name)
  terminated_node_on_chef.destroy
  terminated_node.destroy
  write_to_log("deleted these nodes:#{terminated_node.name}")
#end
```
OR         
- run the command 

```
knife node delete NODENAME
##NODENAME: from 'nodes_to_delete---mm-dd-yyyy-hh.txt' file 
```




