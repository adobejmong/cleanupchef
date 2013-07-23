require 'aws'
require 'aws-sdk'

$initial_config_file = '../localfiles/initial_config.txt'
$cw_metrics_values_file = '../localfiles/cw_metrics.txt'

#Check if file exist
def file_or_directory_exist(directorypath)
  directoryname= File.dirname(directorypath)
  unless File.directory?(directoryname)
    FileUtils.mkdir_p(directoryname)
  end
end

#Open File
def open_file(filepath)
begin
  lines = File.open(filepath).read
  rescue => e
  puts "Could not open file #{filepath}"
  puts e.message
end
return lines
end


#Read File
def read_file(filepath,regex)
  file_or_directory_exist(filepath)
  lines = File.open(filepath).read
  lines.gsub!(/\r\n?/, "\n")
  return lines
end

#Write to File
def write_to_log(stringtowrite)
  File.open("../localfiles/logs.txt", 'ab') do |file| #append to end of file
    file.write(Time.now.strftime("%m-%d-%Y-%H-%m-%S") + ": " + stringtowrite)
  end
end

def get_string_from_file(filepath,regex)
  line_for_regex = ""
  lines = read_file(filepath,regex)
  lines.each_line do |line|
    if (line =~ /#{regex}/)# get access key
      line_for_regex = line.gsub!(/(#{regex})|(\n)/,"")
    end
  end
  return line_for_regex
end

#set AWS Environment
def set_aws_environment (accesskey,secretkey)
  AWS.config(
      :access_key_id     => accesskey,
      :secret_access_key => secretkey
    )
end

#get file from S3 bucket
def get_file_from_bucket(accesskey,secretkey,bucket,filename)
  set_aws_environment(accesskey,secretkey)
  s3 = AWS::S3.new
  file_on_s3= s3.buckets[bucket].objects[filename]
  #Read an object to a file to avoid overloading the system
  File.open("../localfiles/local_#{filename}", 'wb') do |file|
    file_on_s3.read do |chunk|
      file.write(chunk)
    end
  end
  return "../localfiles/local_#{filename}"
end

#get AWS credentials
def get_aws_credentials(filepath,accesskey_regex,secretkey_regex)
  access_key= get_string_from_file(filepath,accesskey_regex)
  secret_key= get_string_from_file(filepath,secretkey_regex)
  return access_key,secret_key
end
  
