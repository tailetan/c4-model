workspace extends ../models.dsl {
    model {       
        # Deployment
        prodEnvironment = deploymentEnvironment "Production" {
            deploymentNode "AWS" {
                tags "Amazon Web Services - Cloud"

                route53 = infrastructureNode "Route 53" {
                    tags "Amazon Web Services - Route 53"
                }

                deploymentNode "ap-southeast-1" {
                    tags "Amazon Web Services - Region"

                    deploymentNode "prod-vpc" {
                        tags "Amazon Web Services - VPC"

                        appLoadBalancer = infrastructureNode "Application Load Balancer" {
                            tags "Amazon Web Services - Elastic Load Balancing ELB Application load balancer"
                        }

                        deploymentNode "eks-cluster" {
                            tags "Amazon Web Services - Elastic Kubernetes Service"
                        
                            deploymentNode "ec2-a" {
                                tags "Amazon Web Services - EC2 Instance"

                                backOfficeAppInstance = containerInstance backOfficeApp
                                searchWebApiInstance = containerInstance searchWebApi
                                adminWebApiInstance = containerInstance adminWebApi
                                publicWebApiInstance = containerInstance publicWebApi
                            }

                            deploymentNode "ec2-b" {
                                tags "Amazon Web Services - EC2 Instance"

                                containerInstance bookEventConsumer
                                containerInstance bookEventSystem
                            }
                        }

                        deploymentNode "Amazon Elasticsearch" {
                            tags "Amazon Web Services - Elasticsearch Service"

                            containerInstance searchDatabase
                        }

                        deploymentNode "PostgreSQL RDS" {
                            tags "Amazon Web Services - RDS"
                            
                            containerInstance bookstoreDatabase
                        }
                    }
                }
            }
            route53 -> appLoadBalancer
            appLoadBalancer -> publicWebApiInstance "Forwards requests to" "[HTTPS]"
            appLoadBalancer -> searchWebApiInstance "Forwards requests to" "[HTTPS]"
            appLoadBalancer -> adminWebApiInstance "Forwards requests to" "[HTTPS]"
        }
    }

    views {
        # Deployment View
        deployment bookstoreSystem prodEnvironment "Dep-001-PROD" "Production deployment on AWS" {
            include *
            autoLayout lr
        }

        theme "https://static.structurizr.com/themes/amazon-web-services-2020.04.30/theme.json"
    }
}
