# Ultima-DeepVariant-Workflow

This workflow runs DeepVariant and quality metrics on Ultima data using Parabricks on AWS. 

[Insert diagram]

This sample comes from XXX sequenced on XXX Ultimate machine. 

### Step 1: Launch AWS EC2 Instance

You can launch an EC2 instance using either the [CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-services-ec2-instances.html#launching-instances) or the [Console Launch Wizard](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-launch-instance-wizard.html) or whichever method you prefer. The instance will need the following properties: 

| Property | Value |
| :---: | :----: |
| AMI | [NVIDIA GPU Optimized AMI](https://aws.amazon.com/marketplace/pp/prodview-7ikjtg3um26wq?sr=0-1&ref_=beagle&applicationId=AWS-EC2-Console) |
| Instance Type | g4dn.12xlarge |
| Storage | 500 GB |

### Step 2: Clone the repo 

```
git@github.com:clara-parabricks-workflows/Ultima-DeepVariant-Workflow.git
```

### Step 3: Run the workflow 

```
cd Ultima-DeepVariant-Workflow 
./run 
```