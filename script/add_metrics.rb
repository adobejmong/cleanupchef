#!/usr/bin/ruby1.8

require 'rubygems'
require 'yaml'
require 'aws-sdk'
require 'aws/cloud_watch'
require '.functions.rb'

#Parameters
nodes_subscribed=get_string_from_file($cw_metrics_values_file,'nodes_subscribed = ')
nodes_registered=get_string_from_file($cw_metrics_values_file,'nodes_registered = ')
nodes_active= get_string_from_file($cw_metrics_values_file,'nodes_active = ')
#Access Key and Secret Key of cloudwatch IAM User
cw_access_key,cw_secret_key = get_aws_credentials($initial_config_file,'cw_accesskey = ','cw_secretkey = ')
#Metrics- namespace, name
namespace = get_string_from_file($initial_config_file,'namespace = ')
metric1 = get_string_from_file($initial_config_file,'metric1 = ')
metric2 = get_string_from_file($initial_config_file,'metric2 = ')
metric3 = get_string_from_file($initial_config_file,'metric3 = ')

#set environment
AWS.config(
        :access_key_id => cw_access_key,
        :secret_access_key => cw_secret_key,
        :region => 'us-east-1'
        )

@cw = AWS::CloudWatch.new
puts "Correct Endpoint? : #{@cw.client.endpoint} "

#First Metric
@namespace = namespace
@name = metric1
@sample_metrics = AWS::CloudWatch::Metric.new(@namespace,@name)
@sample_metrics.put_data [{:value => nodes_subscribed}]

#second Metric
@namespace = namespace
@name = metric2
@sample_metrics = AWS::CloudWatch::Metric.new(@namespace,@name)
@sample_metrics.put_data [{:value => nodes_registered}]

#Third Metric
@namespace = namespace
@name = metric3
@sample_metrics = AWS::CloudWatch::Metric.new(@namespace,@name)
@sample_metrics.put_data [{:value => nodes_active}]

