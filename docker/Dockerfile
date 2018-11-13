FROM tensorflow/tensorflow:1.12.0-gpu

RUN pip install ipykernel

RUN pip install tensorflow_hub

ENV LD_LIBRARY_PATH /usr/lib/nvidia:/usr/local/cuda/lib64:/rootfs/usr/lib/x86_64-linux-gnu

ADD code /code