This project provides a Docker-based environment for building AWS Lambda layers with Python dependencies. It simplifies the process of creating Lambda layers that are compatible with the AWS Lambda runtime environment.

## Project Structure

```
aws-lambda-layer-creator/
├── Dockerfile
├── requirements.txt
└── output/
```

- `Dockerfile`: Contains the Docker configuration for building the Lambda layer
- `requirements.txt`: Lists all Python dependencies to be included in the layer
- `output/`: Directory where the generated Lambda layer ZIP file will be stored

## Prerequisites

- Docker installed on your system
- Basic understanding of AWS Lambda layers
- AWS CLI (for deploying the layer to AWS)

## Dependencies Included

The following Python packages are included in the Lambda layer:
- boto3
- requests
- openai
- pdf2image
- python-dotenv
- psycopg2-binary
- sqlalchemy
- pydantic (v2.9.2)
- pydantic-core

## How It Works

The Dockerfile:
1. Uses Ubuntu as the base image
2. Installs necessary system packages including Python, pip, and PDF-related utilities
3. Creates a Python virtual environment
4. Installs Python packages specified in requirements.txt
5. Packages everything into a ZIP file compatible with AWS Lambda layers

## Usage

1. Build the Docker image:
```bash
docker build --platform="linux/amd64" -t lambda-layer-builder .
```

2. Run the container to generate the layer:
```bash
docker run --platform="linux/amd64" --rm -v $(pwd)/output:/lambda-layer lambda-layer-builder
```

3. The Lambda layer ZIP file will be created in the `output` directory

4. Upload the generated ZIP file to AWS Lambda as a layer

## Important Notes

- The layer is built specifically for Python 3.11
- Packages are compiled for the `manylinux2014_x86_64` platform to ensure compatibility with AWS Lambda
- The layer in this template includes PDF processing capabilities through poppler utilities, but you can customize it to include other dependencies
- Make sure to check AWS Lambda layer size limits (currently 250 MB unzipped)

## Customization

To modify the included dependencies:
1. Edit the `requirements.txt` file
2. Rebuild the Docker image
3. Run the container again to generate a new layer