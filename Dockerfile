# Use the official Ubuntu minimal image
FROM ubuntu:latest

# Install Python, pip, and other necessary packages
RUN apt-get update && \
    apt-get install -y python3 python3-pip python3-venv zip pkg-config poppler-utils libpoppler-cpp-dev && \
    apt-get clean

# Create a directory for the layer
RUN mkdir -p /lambda-layer/python

# Copy the requirements.txt file
COPY requirements.txt /lambda-layer/

# Create a virtual environment
RUN python3 -m venv /lambda-layer/venv

# Activate the virtual environment and install the Python packages
RUN /lambda-layer/venv/bin/pip install --upgrade pip && \
    /lambda-layer/venv/bin/pip install --platform manylinux2014_x86_64 --implementation cp --python-version 3.11 --only-binary=:all: --target=/lambda-layer/python -r /lambda-layer/requirements.txt

# Set the working directory
WORKDIR /lambda-layer

# Zip the contents of the layer
RUN zip -r /lambda-layer.zip python

# Move the zip file to the mounted directory
CMD ["cp", "/lambda-layer.zip", "/lambda-layer/lambda-layer.zip"]