FROM python:2.7.14-alpine3.6
WORKDIR /usr/src
ADD . /usr/src
RUN python setup.py install
ENTRYPOINT ["python", "aws_batch_csv_processor"]
