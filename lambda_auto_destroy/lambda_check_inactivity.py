import boto3
import datetime
import os

def lambda_handler(event, context):
    ec2 = boto3.client('ec2')
    cloudwatch = boto3.client('cloudwatch')

    lb_name = os.environ['LOAD_BALANCER_NAME']

    instances = ec2.describe_instances(Filters=[{'Name': 'tag:Created_By', 'Values': ['ephemeral-deploy']}])

    for reservation in instances['Reservations']:
        for instance in reservation['Instances']:
            instance_id = instance['InstanceId']

            response = cloudwatch.get_metric_statistics(
                Namespace='AWS/ApplicationELB',
                MetricName='RequestCount',
                Dimensions=[
                    {'Name': 'LoadBalancer', 'Value': lb_name},
                ],
                StartTime=datetime.datetime.utcnow() - datetime.timedelta(hours=24),
                EndTime=datetime.datetime.utcnow(),
                Period=86400,
                Statistics=['Sum']
            )

            if not response['Datapoints'] or response['Datapoints'][0]['Sum'] == 0:
                print(f"Terminating idle instance {instance_id}")
                ec2.terminate_instances(InstanceIds=[instance_id])