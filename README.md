This project provides a Docker-based environment for building AWS Lambda layers with Python dependencies. It simplifies the process of creating Lambda layers that are compatible with the AWS Lambda runtime environment.

## Project Structure

```
aws-lambda-layer-creator/
├── Dockerfile
├── requirements.txt
└── output/
```

- `Dockerfile`: Contains the Docker configuration for building the Lambda layer.
- `requirements.txt`: Lists Python dependencies to be included in the layer.
- `output/`: Directory where the generated Lambda layer ZIP file will be stored.

## Prerequisites

- Docker installed on your system.
- Basic understanding of AWS Lambda layers.
- AWS CLI (for deploying the layer to AWS).

## Dependencies Included

The `requirements.txt` in this project currently includes:
- `polars`

You can customize `requirements.txt` to include any other packages you need.

## How It Works

The Dockerfile performs the following steps to create the Lambda layer:
1. Uses the official `python:3.13-slim` image as a lightweight base.
2. Installs the `zip` utility, which is necessary for packaging the layer.
3. Sets up an internal working directory (`/buildarea`) where the layer components will be assembled. This directory is distinct from the final output mount point to avoid conflicts.
4. Copies your `requirements.txt` file into this build area.
5. Installs the Python packages listed in `requirements.txt` directly into a `python` subdirectory within `/buildarea`. It uses specific `pip install` flags (`--platform manylinux2014_x86_64`, `--implementation cp`, `--python-version 3.11`, `--only-binary=:all:`, `--target=python`) to ensure the packages are compatible with the AWS Lambda execution environment for Python 3.13.
6. Archives the `python` subdirectory (containing all installed dependencies) into a `lambda-layer.zip` file located within the `/buildarea`.
7. The container's default command (`CMD`) is configured to copy this `lambda-layer.zip` from `/buildarea` to the `/lambda-layer/` directory. When you run the container with a volume mount (as shown in the Usage section), `/lambda-layer/` points to your local `output` directory, making the ZIP file available on your host machine.

## Usage

1.  **Build the Docker image:**
    This command builds the Docker image and tags it as `lambda-layer-builder`. It also includes a step to prune any dangling images after a successful build to keep your system clean.
    ```bash
    docker build --platform="linux/amd64" -t lambda-layer-builder . && docker image prune -f
    ```

2.  **Run the container to generate the layer:**
    This command runs the `lambda-layer-builder` container.
    - `--platform="linux/amd64"` ensures the build is for the Lambda environment.
    - `--rm` automatically removes the container when it exits.
    - `-v $(pwd)/output:/lambda-layer` mounts your local `./output` directory to `/lambda-layer` inside the container. The generated ZIP file will be copied here.
    ```bash
    docker run --platform="linux/amd64" --rm -v $(pwd)/output:/lambda-layer lambda-layer-builder
    ```

3.  **Retrieve the layer:**
    The `lambda-layer.zip` file will be created in your local `output` directory.

4.  **Deploy to AWS:**
    Upload the generated `lambda-layer.zip` file to AWS Lambda as a new layer version via the AWS Management Console, AWS CLI, or your preferred Infrastructure as Code tool.

## Important Notes

- The layer is built specifically for Python 3.11.
- Packages are compiled for the `manylinux2014_x86_64` platform to ensure compatibility with AWS Lambda.
- You can customize the `requirements.txt` to include any dependencies your Lambda function needs.
- Always be mindful of AWS Lambda layer size limits (currently 250 MB unzipped for the function and all layers combined).

## Customization

To modify the included Python dependencies:
1. Edit the `requirements.txt` file to add, remove, or change package versions.
2. Rebuild the Docker image using the command in Step 1 of the "Usage" section.
3. Run the container again (Step 2 of "Usage") to generate a new `lambda-layer.zip` file with your updated dependencies.