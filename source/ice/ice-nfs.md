# EFS Creation

## Verify AWS Region

For this example we will use the built-in default VPC for the lab as well as remain in the US-EAST-1 Region

## Create Security Groups

### Create SG for EC2

Create a security group for SSH Access

    1) Security Group Name EC2-SG
    2) Description - Allow SSH Access for Developers
    2) VPC (default)
    3) Inbound Rules
        1) SSH
        2) Source 0.0.0.0/0 for this lab but you would want to lock this down in production
    4) Outbound - leave all traffic on 0.0.0.0/0

### Create SG for EFS

Create a security group for the EFS

    1) Security Group Name EFS-SG
    2) Description - Allow Access to Website EFS Drive
    2) VPC (default)
    3) Inbound Rules
        1) NFS
        2) Source EC2-SG (scroll down to see the security groups)
    4) Outbound - leave all traffic on 0.0.0.0/0

### Verify settings

Click on the individual security groups and verify that the inbound and outbound rules are correct.

EC2-SG

    1) Inbound - SSH, TCP, 22, 0.0.0.0/0
    2) Outbound - All traffic, All, All, 0.0.0.0/0

EFS-SG

    1) Inbound - NFS, TCP, 2049, sg-XXXXXXXXXXXXXXXXX / EC2-SG
    2) Outbound - All traffic, All, All, 0.0.0.0/0

## Create EFS

1) Create file system
2) Customize button

    1) Name - Website Drive
    2) Regional
    3) Uncheck "Enable automatic backups"
    3) Lifecycle Management -> Transition into Archive - Select None
    4) Throughput - Bursting
    5) Next

    1) Update all availability zones by
        1) Remove the default security group
        2) Add the EFS-SG
    2) Next
    3) Next (again)
    4) Create

## Create an EC2 Instance

Go to AWS and create an ec2 instance. Use the 2023 Linux AMI. These should be in the us-east-1 region.

1) Create Instance
2) Give it a name
3) Select the vockey for the Key Pair
4) Click Edit on Network Settings

    1) Choose a subnet from that region (us-east-1c)
    2) Select existing security group
    3) Common Security Group - Select EC2-SG
5) Launch Instance



## Connect to the EC2 Instance

## mount the drive

1) sudo mkdir /mnt/efs
2) sudo mkdir /mnt/efs/fs1

Go out to your EFS console

1) Click on the WebDrive
2) Click attach
3) Select the *Using NFS Client"

Back on your console

1) cd /mnt/efs
1) Copy your command (it should look like this)
    1) sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport fs-XXXXXXXXXXXXXXX.efs.us-east-1.amazonaws.com:/ fs1
    2) MAKE SURE YOU CHANGE THE efs at the end to fs1

1) give your user access
2) sudo chown ec2-user:ec2-user /mnt/efs/fs1
3) sudo chmod 755 /mnt/efs/fs1

## Create another EC2 Instances

## Do the automatic add from the console

Create an EC2 instance.

1) Give it a name
2) Choose vockey for the key pair
3) Network settings -> Edit

    1) Choose a subnet (e.g. us-east-1b)
    2) Select existing security group
    3) EC2-SG

4) Configure Storage -> Advanced
    1) File systems -> Show Details
    2) Make sure EFS is selected
    3) Add shared file system
    4) Select the file system if you don't see it
    5) Confirm mount point is /mnt/efs/fs1
    6) Uncheck Automatically create and attach security groups
    7) Leave Automatically mount shared file system... checked
4) Launch instance


Connect to the server

Make sure both checks pass to ensure that the mount has been added and that permissions have been given

cd /mnt/efs/fs1
ls -la

Now you can create files on either ec2 instance and have it show up on the other

touch "first.txt"

switch to the other computer

ls -la

touch "second.txt"

switch back to first ec2 instance

ls -la




