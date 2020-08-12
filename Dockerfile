FROM tensorflow/tensorflow:1.15.2-gpu-py3

RUN add-apt-repository "deb http://security.ubuntu.com/ubuntu xenial-security main" && apt-get update && apt-get install -y \
  # developer tools
  build-essential \
  curl \
  cmake \
  git \
  wget \
  unzip \
  yasm \
  pkg-config \
  gunicorn \
  # image formats support
  libtbb2 \
  libtbb-dev \
  libjpeg-dev \
  libpng-dev \
  libtiff-dev \
  libjasper-dev \
  libhdf5-dev \
  # video formats support
  libavcodec-dev \
  libavformat-dev \
  libswscale-dev \
  libv4l-dev \
  libxvidcore-dev \
  libx264-dev

WORKDIR /

RUN wget https://github.com/opencv/opencv_contrib/archive/4.4.0.zip \
  && unzip 4.4.0.zip \
  && rm 4.4.0.zip

RUN wget https://github.com/opencv/opencv/archive/4.4.0.zip \
  && unzip 4.4.0.zip \
  && mkdir /opencv-4.4.0/build \
  && cd /opencv-4.4.0/build \
  && cmake -DBUILD_TIFF=ON \
  -DBUILD_opencv_java=OFF \
  -DOPENCV_EXTRA_MODULES_PATH=/opencv_contrib-4.4.0/modules \
  -DWITH_CUDA=OFF \
  -DENABLE_AVX=ON \
  -DWITH_OPENGL=ON \
  -DWITH_OPENCL=ON \
  # cannot download ippicv
  -DWITH_IPP=ON \
  -DWITH_TBB=ON \
  -DWITH_EIGEN=ON \
  -DWITH_V4L=ON \
  -DBUILD_TESTS=OFF \
  -DBUILD_PERF_TESTS=OFF \
  -DCMAKE_BUILD_TYPE=RELEASE \
  -DCMAKE_INSTALL_PREFIX=$(python -c "import sys; print(sys.prefix)") \
  -DPYTHON_EXECUTABLE=$(which python) \
  -DPYTHON_INCLUDE_DIR=$(python -c "from distutils.sysconfig import get_python_inc; print(get_python_inc())") \
  -DPYTHON_PACKAGES_PATH=$(python -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())") .. \
  && make install \
  && rm /4.4.0.zip \
  && rm -r /opencv-4.4.0 \
  && ldconfig

# Python dependencies
RUN pip --no-cache-dir install \
  cython \
  'numpy<1.19.0' \
  hdf5storage \
  h5py \
  scipy \
  py3nvml \
  keras \
  Pillow \
  pandas \
  matplotlib \
  jsonschema \
  html5lib && pip install --no-binary :all: falcon
