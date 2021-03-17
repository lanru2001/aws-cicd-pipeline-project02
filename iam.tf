resource "aws_iam_role" "build_role" {
  name               = "build-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "codebuild.amazonaws.com"
          
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "codebuild_policy" {
  name        = "codebuild-policy"
  path        = "/service-role/"
  description = "Policy used in trust relationship with CodeBuild"
  policy      = <<POLICY
{
	"Version": "2012-10-17",
	"Statement": [{
			"Effect": "Allow",
			"Resource": [
				"*"
			],
			"Action": [
				"logs:CreateLogGroup",
				"logs:CreateLogStream",
				"logs:PutLogEvents"
                               
			]
		},
		{
			"Effect": "Allow",
			"Action": [
				"s3:PutObject",
				"s3:GetObject",
				"s3:GetObjectVersion",
				"s3:GetBucketAcl",
				"s3:GetBucketLocation"
			],
			"Resource": [
				"*"
			]
		},
		{
			"Effect": "Allow",
			"Action": [
				"codebuild:CreateReportGroup",
				"codebuild:CreateReport",
				"codebuild:UpdateReport",
				"codebuild:BatchPutTestCases",
				"codebuild:*",
				"codebuild:BatchPutCodeCoverages"
			],
			"Resource": [
				"arn:aws:codebuild:us-east-2:216147165517:*"
			]
		}
	]
}
POLICY
}


resource "aws_iam_role_policy_attachment" "build_pipeline" {
  role       = aws_iam_role.build_role.name
  policy_arn = aws_iam_policy.codebuild_policy.arn
}


resource "aws_iam_role" "codepipeline_role" {
  name = "test-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
     
    }
  ]
}
EOF
}

# Codedeploy policy  
#resource "aws_iam_role_policy" "codedeploy_policy" {
#  name = "deploy_policy"
#  role = aws_iam_role.deploy_role.id
#
#  policy = <<POLICY
#{
#  "Version": "2012-10-17",
#  "Statement": [
#    {
#      "Effect":"Allow",
#      "Action": [
#        "s3:GetObject",
#        "s3:GetObjectVersion",
#        "s3:GetBucketVersioning",
#        "s3:PutObject",
#        "ec2:DescribeNetworkInterfaces",
#        "ec2:CreateNetworkInterface",
#        "ec2:DeleteNetworkInterface",
#        "ec2:DescribeInstances",
#        "ec2:AttachNetworkInterface",
#        "ec2:RunInstances",
#        "ec2:CreateTags"
#      ],
#      "Resource": [
#        "${aws_s3_bucket.app_web.arn}",   
#        "${aws_s3_bucket.app_web.arn}/*",
#        "*"
#      ]
#    }
#  ]
#}
#POLICY
#}

#data "aws_kms_alias" "s3kmskey" {
# name = "alias/myKmsKeyMainKey"
#}


resource "aws_iam_role" "deploy_role" {
  name               = "deploy-role"
  assume_role_policy = <<EOF
{
   "Version": "2012-10-17",
   "Statement": [
      {
         "Sid": "",
         "Effect": "Allow",
         "Principal": {
            "Service": [
               "codedeploy.amazonaws.com"
            ]
         },
         "Action": "sts:AssumeRole"
         }
   ]
}
EOF
}


resource "aws_iam_role_policy" "codepipeline_policy" {
  name   = "codepipeline_policy"
  role   = aws_iam_role.codepipeline_role.id
  policy = <<EOF
{
    "Statement": [
        {
            "Action": [
                "iam:PassRole"
            ],
            "Resource": "*",
            "Effect": "Allow",
            "Condition": {
                "StringEqualsIfExists": {
                    "iam:PassedToService": [
                        "cloudformation.amazonaws.com",
                        "elasticbeanstalk.amazonaws.com",
                        "ec2.amazonaws.com",
                        "ecs-tasks.amazonaws.com"
                    ]
                }
            }
        },
        {
            "Action": [
                "codecommit:CancelUploadArchive",
                "codecommit:GetBranch",
                "codecommit:GetCommit",
                "codecommit:GetUploadArchiveStatus",
                "codecommit:UploadArchive"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "codedeploy:CreateDeployment",
                "codedeploy:GetApplication",
                "codedeploy:GetApplicationRevision",
                "codedeploy:GetDeployment",
                "codedeploy:GetDeploymentConfig",
                "codedeploy:RegisterApplicationRevision"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "codestar-connections:UseConnection"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "elasticbeanstalk:*",
                "ec2:*",
                "elasticloadbalancing:*",
                "autoscaling:*",
                "cloudwatch:*",
                "s3:*",
                "sns:*",
                "cloudformation:*",
                "rds:*",
                "sqs:*",
                "ecs:*"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "lambda:InvokeFunction",
                "lambda:ListFunctions"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "opsworks:CreateDeployment",
                "opsworks:DescribeApps",
                "opsworks:DescribeCommands",
                "opsworks:DescribeDeployments",
                "opsworks:DescribeInstances",
                "opsworks:DescribeStacks",
                "opsworks:UpdateApp",
                "opsworks:UpdateStack"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "cloudformation:CreateStack",
                "cloudformation:DeleteStack",
                "cloudformation:DescribeStacks",
                "cloudformation:UpdateStack",
                "cloudformation:CreateChangeSet",
                "cloudformation:DeleteChangeSet",
                "cloudformation:DescribeChangeSet",
                "cloudformation:ExecuteChangeSet",
                "cloudformation:SetStackPolicy",
                "cloudformation:ValidateTemplate"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "codebuild:BatchGetBuilds",
                "codebuild:StartBuild",
                "codebuild:BatchGetBuildBatches",
                "codebuild:StartBuildBatch"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Effect": "Allow",
            "Action": [
                "devicefarm:ListProjects",
                "devicefarm:ListDevicePools",
                "devicefarm:GetRun",
                "devicefarm:GetUpload",
                "devicefarm:CreateUpload",
                "devicefarm:ScheduleRun"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "servicecatalog:ListProvisioningArtifacts",
                "servicecatalog:CreateProvisioningArtifact",
                "servicecatalog:DescribeProvisioningArtifact",
                "servicecatalog:DeleteProvisioningArtifact",
                "servicecatalog:UpdateProduct"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "cloudformation:ValidateTemplate"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ecr:DescribeImages"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "states:DescribeExecution",
                "states:DescribeStateMachine",
                "states:StartExecution"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "appconfig:StartDeployment",
                "appconfig:StopDeployment",
                "appconfig:GetDeployment"
            ],
            "Resource": "*"
        }
    ],
    "Version": "2012-10-17"
}
EOF
}

#resource "aws_iam_role_policy_attachment" "AWSCodeDeployRole" {
#  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
#  role       = aws_iam_role.deploy_role.name
#}


resource "aws_iam_role_policy" "deploy_policy" {
  name = "deploy_policy"
  role = aws_iam_role.deploy_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect":"Allow",
      "Action": [
        "s3:GetObject",
        "s3:GetObjectVersion",
        "s3:GetBucketVersioning",
        "s3:PutObject",
        "ec2:*",
        "cloudwatch:*",
        "autoscaling:*",
        "iam:PassRole"
      ],
      "Resource": [
        "*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "codebuild:BatchGetBuilds",
        "codebuild:StartBuild"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

