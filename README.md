# AWS ECS CI/CD Pipeline with GitHub Actions and Terraform

A hands-on DevOps project demonstrating an end-to-end CI/CD pipeline for deploying a Dockerized web application to **Amazon ECS Fargate**.

The infrastructure is provisioned with **Terraform**, while **GitHub Actions** handles Continuous Integration and Continuous Deployment. GitHub authenticates to AWS securely using **OpenID Connect (OIDC)** without storing long-lived AWS access keys.

## Architecture

```text
Developer
   |
   | git push
   v
GitHub Repository
   |
   v
GitHub Actions
   |
   |---- CI Pipeline ----------------------|
   |                                      |
   |  1. Checkout source code             |
   |  2. Authenticate to AWS using OIDC   |
   |  3. Build Docker image               |
   |  4. Tag image with Git commit SHA    |
   |  5. Push image to Amazon ECR         |
   |                                      |
   |---- CD Pipeline ----------------------|
   |                                      |
   |  6. Retrieve ECS task definition     |
   |  7. Insert the new ECR image         |
   |  8. Register new task revision       |
   |  9. Update ECS service               |
   | 10. Wait for service stability       |
   |                                      |
   v
Amazon ECS Fargate
   |
   v
Application Load Balancer
   |
   v
Web Application
```

## Technologies Used

- **AWS ECS Fargate** — Runs the containerized application
- **Amazon ECR** — Stores Docker images
- **Application Load Balancer (ALB)** — Routes HTTP traffic to ECS tasks
- **AWS IAM & OIDC** — Secure GitHub-to-AWS authentication
- **Amazon CloudWatch** — Stores ECS container logs
- **ECS Service Auto Scaling** — Scales tasks based on CPU utilization
- **Terraform** — Provisions and manages AWS infrastructure
- **Docker** — Packages the application into a container image
- **GitHub Actions** — Automates CI/CD
- **Nginx** — Serves the web application

## CI/CD Workflow

The workflow is divided into two jobs:

### Continuous Integration — Build

When code is pushed to the `main` branch, GitHub Actions:

1. Checks out the repository.
2. Authenticates to AWS through OIDC.
3. Logs in to Amazon ECR.
4. Builds the Docker image.
5. Tags the image using the Git commit SHA.
6. Pushes the image to ECR.

Using the commit SHA creates an immutable link between the source-code version and the Docker image deployed to AWS.

### Continuous Deployment — Deploy

The `deploy` job runs only after the `build` job succeeds.

It:

1. Authenticates to AWS using OIDC.
2. Determines the URI of the newly built image.
3. Downloads the current ECS task definition.
4. Updates the container definition with the new SHA-tagged image.
5. Registers a new ECS task-definition revision.
6. Updates the ECS service.
7. Waits for the new deployment to become stable.

This provides an automated deployment path from:

```text
git push → GitHub Actions → Docker → ECR → ECS → Fargate → ALB
```

## Infrastructure as Code

Terraform provisions the AWS infrastructure, including:

- ECS cluster
- ECS Fargate service
- ECS task definition
- Application Load Balancer
- Target group and listener
- Security groups
- CloudWatch log group
- ECS task execution IAM role
- ECS Service Auto Scaling

The project uses the default VPC and its subnets for the lab environment.

## Terraform and CI/CD Ownership

Terraform manages the underlying infrastructure, while GitHub Actions manages application deployments.

The ECS service therefore ignores changes to:

```hcl
lifecycle {
  ignore_changes = [
    desired_count,
    task_definition
  ]
}
```

`desired_count` can be modified by ECS Auto Scaling, while `task_definition` can be updated by the GitHub Actions deployment pipeline.

This prevents Terraform from unintentionally rolling back application deployments performed by CI/CD.

## Security

GitHub Actions authenticates to AWS using **OIDC federation** and an IAM role.

```text
GitHub Actions
      |
      | OIDC token
      v
AWS IAM Role
      |
      +----> Amazon ECR
      |
      +----> Amazon ECS
```

This avoids storing permanent AWS access keys and secret keys in the GitHub repository.

## Repository Structure

```text
ecs-cicd-pipeline/
├── .github/
│   └── workflows/
│       └── cicd.yml
├── infra/
│   └── main.tf
├── .gitignore
├── Dockerfile
├── index.html
└── README.md
```

## Deployment Flow

A normal application deployment requires only:

```bash
git add .
git commit -m "update application"
git push origin main
```

GitHub Actions then automatically builds the new container image, pushes it to ECR, creates a new ECS task-definition revision, updates the ECS service, and waits for the deployment to stabilize.

No manual ECS deployment is required.

## What I Learned

Through this project, I gained hands-on experience with:

- Building an end-to-end CI/CD pipeline with GitHub Actions
- Using OIDC to securely authenticate GitHub Actions with AWS
- Building, tagging, and pushing Docker images to Amazon ECR
- Using Git commit SHAs for versioned container images
- Deploying new application versions to ECS Fargate
- Working with ECS task definitions, services, and Application Load Balancers
- Provisioning AWS infrastructure with Terraform
- Managing Terraform drift when application deployments are handled by CI/CD
- Troubleshooting IAM permissions, OIDC trust policies, Docker image tags, and ECS deployments
- 
## Project Status

**Completed — End-to-end CI/CD deployment successfully tested.**

A change pushed to the `main` branch is automatically built, packaged as a Docker image, stored in Amazon ECR, deployed as a new ECS task-definition revision, and rolled out through the ECS Fargate service.

---

### Author

**Ruffin Kamiantako**

DevOps | Cloud | AWS | Terraform | Docker | Kubernetes | GitHub Actions
