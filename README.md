# DBT Accounting Warehouse

This repository provides a **dbt solution** designed to help manage and analyze personal finances effectively. The repository includes tools, pipelines, and configurations designed to streamline the transformation process while ensuring scalability and maintainability.

It uses BigQuery as the adapter since it serves as the Data Warehouse. The solution is containerized into a Docker image, which is deployed as a Cloud Run Job for daily execution which is ensured by a cloud scheduler. Additionally, the deployed solution includes policy-based alerting that sends email notifications in case of execution errors.

## Features

- **Development Environment**: Pre-configured development container for consistent setup. This allows you to execute dbt from your local environment for testing purposes, pointing to testing schemas.
- **Terraform Configuration**: Simplified infrastructure management using Terraform, ensuring reproducibility and scalability.
- **Pipeline Integration**: Automated pipelines for testing and deployment, enhancing code quality and streamlining the release process.

## Development environment

Recommended development enviroment is VSCode Dev Containers extension. The configuration and set up of this dev container is already defined in `.devcontainer/devcontainer.json` so setting up a new containerised dev environment on your machine is straight-forward.

Pre-requisites:
- docker installed on your machine and available on your `PATH`
- [Visual Studio Code](https://code.visualstudio.com/) (VSCode) installed on your machine
- [Dev Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) vscode extension installed

Steps:
- In VSCode go to `View -> Command Pallet` and search for the command `>Dev Containers: Rebuild and Reopen in Container`

The first time you open the workspace within the container it'll take a few minutes to build the container, setup the virtual env and then login to gcloud. At the end of this process you will be presented with a url and asked to provide an authorization. Simply follow the url, permit the access and copy the auth code provided at the end back into to the terminal and press enter. 

### Configure Git 

For seamless Git usage in a Dev Container, create a local script at .devcontainer/git_config.sh (do not push this file to the repository) and set your GitHub account name and email:

```bash
#!/bin/bash

git config --global user.name "your github account name"
git config --global user.email "your github account email"
```

### Local Execution

The dev container configuration enables local execution of dbt commands seamlessly. By default, a development environment is set up in BigQuery with schemas prefixed by `dev_`, ensuring a clear separation from production data. This allows for safe testing and iteration during development. Additionally, the configuration in the `profiles.yml` file provides the flexibility to execute dbt commands against the production environment if needed, ensuring consistency across environments.

### Dry testing

The CI/CD pipeline includes a **dbt dry run** step to ensure the security and reliability of the dbt models before deployment. This step validates the models by simulating their execution without making any changes to the target database. By doing so, it ensures that the models are free from errors, follow best practices, and do not introduce any unintended consequences during deployment. This process enhances the overall quality and safety of the dbt transformations.

## CI/CD - Pipeline Integration
There are 2 CI/CD pipelines implemented as GitHub Actions:

1. **Testing**: This pipeline is defined in the `.github/workflows/testing.yaml` file. It is triggered on every pull request, what runs `dbt-dry-run`. In case of failure, the pipeline will block the merge process, ensuring that only reliable code is integrated into the main branch.

2. **Deployment**: The deployment process is managed through two GitHub Actions workflows. The first workflow, `.github/workflows/terraform-validate.yaml`, validates the Terraform code, blocking merge in case of failures. The second workflow, `.github/workflows/terraform-apply.yaml`, executes after a merge to deploy the changes to Google Cloud Platform (GCP).

## Deployment implementation

The Terraform code in this repository automates the deployment of the solution as a Cloud Run Job. It provisions and configures the necessary resources to ensure seamless ingestion and processing of data. 

The Terraform code automates the deployment process by managing the following components:

1. **Cloud Run Job**:
    - Executes the containerized dbt solution on a scheduled basis.

2. **Cloud Scheduler Job**:
    - Triggers the Cloud Run Job daily.

3. **Log-based Alerting Policy**:
    - Sends email notifications in case of execution errors or failures.


### Considerations

The Terraform code is designed to be executed by the workflows defined in `.github/workflows/terraform-validate.yaml` and `.github/workflows/terraform-apply.yaml`. 

The backend for this solution is configured to reside in Google Cloud Storage (GCS). If you plan to reuse this code, ensure you update the backend bucket name accordingly.

If you want to execute the solution locally, follow these steps:

1. Outside the dev container, build the Docker image:
    ```bash
    docker build -t LOCATION-docker.pkg.dev/PROJECT_ID/REPOSITORY_NAME/IMAGE_NAME:TAG .
    ```

2. Push the Docker image to Artifact Registry:
    ```bash
    docker push LOCATION-docker.pkg.dev/PROJECT_ID/REPOSITORY_NAME/IMAGE_NAME:TAG
    ```

3. Optionally, add additional tags to the image:
    ```bash
    docker tag LOCATION-docker.pkg.dev/PROJECT_ID/REPOSITORY_NAME/IMAGE_NAME:TAG LOCATION-docker.pkg.dev/PROJECT_ID/REPOSITORY_NAME/IMAGE_NAME:NEW_TAG
    docker push LOCATION-docker.pkg.dev/PROJECT_ID/REPOSITORY_NAME/IMAGE_NAME:NEW_TAG
    ```

4. Execute the Terraform code, providing a valid `TAG` for your Docker image.

**Note**: Ensure you have the necessary permissions and configurations to interact with Google Cloud's Artifact Registry and Terraform. 


### Prerequisites for Terraform Execution

Before the Terraform code can be executed, ensure the following:

1. **Cloud Function Service Account**:
    - Provide a Service Account for the Cloud Run Job with the following roles:
      - `roles/bigquery.dataEditor`
      - `roles/bigquery.jobUser`
      - `roles/run.invoker`

2. **Terraform Execution Permissions**:
    - Either your user account or the Service Account used to run the Terraform code must have the following roles:
      - `roles/iam.serviceAccountUser` on the Service Account mentioned in the previous point.
      - `roles/storage.insightsCollectorService`
      - `roles/cloudfunctions.admin`
      - `roles/cloudscheduler.admin`
      - `roles/artifactregistry.writer`

    
If the dbt models require access to data sources stored in Google Sheets, you must grant the Service Account executing the jobs **Viewer** permissions directly on the respective Google Sheets. This ensures the Service Account can read the data during execution.

To reuse the GitHub Action, follow these steps:

1. **Create a Workload Identity Provider (WIP):**  
   This enables keyless authentication for GitHub Actions.  
   - [Learn why this is needed](https://cloud.google.com/blog/products/identity-security/enabling-keyless-authentication-from-github-actions).  
   - [Follow these instructions](https://docs.github.com/en/actions/security-for-github-actions/security-hardening-your-deployments/configuring-openid-connect-in-google-cloud-platform).

2. **Set up Service Account:**  
   - Grant the Terraform Executor Service Account the necessary permissions to execute Terraform code as indicated before.
   - Assign the role `roles/iam.workloadIdentityUser`.
   - Set the Service Account as the principal for the Workload Identity Provider created in step 1.

3. **Provide secrets:**
    - `WORKLOAD_IDENTITY_PROVIDER` & `SERVICE_ACCOUNT_EMAIL` must be provided as Github Actions Secrets.
