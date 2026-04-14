Terraform structure for root and modules:
the reason that I split the terraform into config and core and services is to provide ease of migration.
Like if we have another business unit or squad or ... that needs a completely isolated env, simply copy pasying the code and changing the parameters in the config module would solves over 90% of the required changes.
Also the core root module has a clear mission which is provisioning the very basic mandatory things that should be in all of our accounts.
like the ECR repos, AWS Secrets, backend S3 bucket and VPC flow log Bucket.

The reason of having the services folder is to be able to expand the repo. 
Like for a single Squad/BU we have right now one cluster in Ireland, what if we wanted to have another one in London? then it can be so clean and easy to follow hierarchy via another directory in services like: eks-euw-2

also isolating TF in directories with different state files has its benifits and trade-offs and I'm fully aware of it and the reason that I choose the separation of the state is to have faster terraform runs and avoid steping on each others toes while workiing on infra in big scale and more than 1 devops engineer as each run will lock others from updating the infra so separated states will allow more concurrent runs and also safer to maintain as messing with one state won't ruin the whole infra.

regarding the modules part of terraform:
I could have created a giantic module and call it infra so it could provision everything in one module.
But I rather preffered to have the fully granulary separated so if needed we can use them separately as I used for example one iam module in the root module for the aws LB controller. if I coded that part inside the eks or vpc module, then I was forced to repeat myself. This is the pattern I see in all community terraform modules and I follow the same approach if it be aligned with team's coding style.

