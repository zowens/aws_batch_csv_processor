#!/usr/bin/env python
import setuptools

requirements = [
    'Click>=6.0',
    'boto>=2.13.2',
    'boto3>=1.4.7',
    'botocore>=1.7.33'
]

setuptools.setup(
    name="aws_batch_csv_processor",
    version="0.1.0",
    url="https://github.com/zowens/aws_batch_csv_processor",

    author="Zack Owens",
    author_email="zowens2009@gmail.com",

    description="CSV processor for AWS Batch",

    packages=setuptools.find_packages(),

    install_requires=requirements,

    classifiers=[
        'Development Status :: 2 - Pre-Alpha',
        'Programming Language :: Python',
        'Programming Language :: Python :: 2',
        'Programming Language :: Python :: 2.7',
        'Programming Language :: Python :: 3',
        'Programming Language :: Python :: 3.4',
        'Programming Language :: Python :: 3.5',
    ],
)
