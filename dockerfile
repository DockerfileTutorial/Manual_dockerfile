FROM mypython:3.8-alpine-changed-url as opencv_builder

COPY . /work
WORKDIR /work

RUN apk add --update --no-cache build-base linux-headers cmake \
	&& apk add --no-cache -t opencv_deps libpng-dev libjpeg \
	&& mkdir -pv build \
	&& cd build && ls -lh \
	&& cmake -DCMAKE_BUILD_TYPE=RELEASE -DCMAKE_INSTALL_PREFIX=/usr/local  -DCMAKE_C_COMPILER=gcc -DCMAKE_CXX_COMPILER=g++ -DBUILD_DOCS=NO -DBUILD_opencv_python3=ON -DPYTHON3_INCLUDE_DIR=/usr/local/include/python3.8 -DPYTHON3_EXECUTABLE=/usr/local/bin/python -DPYTHON3_LIBRARY=/usr/local/lib/libpython3.so -DPYTHON3_PACKAGES_PATH=/usr/local/lib/python3.8/site-packages -DPYTHON3_NUMPY_INCLUDE_DIRS=/usr/local/lib/python3.8/site-packages/numpy/core/include -DOPENCV_GENERATE_PKGCONFIG=ON .. \
	&& make -j6 && make install/strip
	
	
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib64

# build darknet 
WORKDIR /work/darknet
RUN make \
    && ./darknet 
   
# Instead of delete all fucking files, this time i chose to multi-stage build 
FROM mypython:3.8-alpine-changed-url 

WORKDIR /work
COPY --from=opencv_builder /usr/local /usr/local
COPY --from=opencv_builder /work/darknet/darknet /usr/local/bin

RUN apk add --no-cache -t for_darknet libc-dev libstdc++ libgcc libgomp \
	&& apk add --no-cache -t opencv_deps libpng-dev libjpeg
	
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib64	

RUN darknet

CMD ['sh']





