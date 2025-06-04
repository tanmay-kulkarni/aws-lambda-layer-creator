# Use the official Python slim image as a base
FROM python:3.13-slim

# Install zip utility
RUN apt-get update && \
    apt-get install -y zip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set a working directory for building the layer's contents
# This directory is internal to the image and won't be affected by runtime volume mounts
WORKDIR /buildarea
RUN mkdir python

# Copy the requirements file into the build area
COPY requirements.txt .

# Install Python dependencies into the 'python' subdirectory
# These flags ensure compatibility with the AWS Lambda environment
RUN pip install \
    --platform manylinux2014_x86_64 \
    --implementation cp \
    --python-version 3.13 \
    --only-binary=:all: \
    --target=python \
    -r requirements.txt

# Create the zip file containing the 'python' directory with its installed packages
RUN zip -r lambda-layer.zip python

# The CMD instruction will be executed when the container runs.
# It copies the generated zip file from the internal build area
# to the '/lambda-layer/' directory, which is expected to be a mounted volume
# from the host, allowing the zip file to be accessed on the host system.
CMD ["cp", "/buildarea/lambda-layer.zip", "/lambda-layer/lambda-layer.zip"]
