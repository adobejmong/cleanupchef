The script detect terminated nodes and offers the possibility to delete them from the Chef server

####BEFORE YOU START

- [1] Chef Configuration File
   - Get your chef-repo-specific configuration details for Knife (e.g., knife.rb)
   - Get the number of nodes subscribed (nodes allowed by Opscode)
- [2] AWS accounts Credentials 
   - Get your AWS Accounts Credentials (Access Key and Secret Key) of IAM users that are authorized to run 'ec2-describe-instances'
   - Place them in a file (e.g, credentials.txt)
   - Check the file localfiles/credentials for the format
- [3] S3 Bucket
   - Create an S3 Bucket and get its name
   - Create an IAM user that can access this bucket
    Get the IAM user credentials (Access Key and Secret Key)
- [4] Cloud Watch
    - Create an IAM user that can run Cloud Watch commands
    - Choose a namespace and metrics names
    

####COPY FILES TO S3 BUCKET (from Step (3))

- Chef configuration File (Step (1))
- The validation client's private key
- Credentials file in Step (3)
    
####EDIT CONFIGURATION FILE

Before you run the script:
Create 'initial_config.txt' from the template below file under /localfiles and 
Edit the fields by replacing 'from step (x)' with the corresponding values from the section above. 
!!!!!Please make sure to keep the space before and after the =.

################Template###########################
#Main Credentials: S3 bucket Access and Secret Keys
s3_accesskey = from step (3)
s3_secretkey = from step (3)
#Bucket name
s3_bucket_name = from step (3)
#AWS Accounts Credentials File
aws_accounts_file = from step (2)
#Chef Config file (knife file)
chef_config_file = from step (1)
#Number of nodes subscribed
chef_subscribed_nodes = from step (1)
#CloudWatch IAM User Credentials
cw_access_key = from step (4)
cw_secret_key = from step (4)
#Cloudwatch Metrics
namespace = from step (4)
metric1 = from step (4)
metric2 = from step (4)
metric3 = from step (4)


####RUN THE SCRIPT

# ruby cleanupchef.rb


####OUTPUT

1- Log file (logs.txt) under output
2- Cloud Watch values (cw_metrics.txt) under output 
3- Terminated instances (nodes_to_delete---mm-dd-yyyy-hh.txt)
4- Script to run to delete nodes from the chef server #TODO

####RUN CLOUDWATCH SCRIPT
#TODO

####BRUN DELETE SCRIPT
#TODO

####
