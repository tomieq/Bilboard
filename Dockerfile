FROM swift:6.1

RUN apt-get update -y \
	&& apt-get install -y --no-install-recommends libgd-dev pkg-config \
	&& rm -rf /var/lib/apt/lists/*

WORKDIR /workspace

COPY Package.swift Package.resolved ./
COPY Sources ./Sources
COPY Tests ./Tests

RUN swift package resolve

CMD ["swift", "test", "--jobs", "1"]