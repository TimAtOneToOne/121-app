FLUTTER := $(if $(wildcard .tmp/flutter-sdk/bin/flutter),.tmp/flutter-sdk/bin/flutter,flutter)
DART := $(if $(wildcard .tmp/flutter-sdk/bin/dart),.tmp/flutter-sdk/bin/dart,dart)

.PHONY: run check build demo
run:
	$(FLUTTER) run -d chrome

check:
	$(DART) format --output=none --set-exit-if-changed lib test
	$(FLUTTER) analyze
	$(FLUTTER) test

build:
	$(FLUTTER) build web

demo: build
	python3 -c "import shutil; shutil.make_archive('.tmp/121-demo', 'zip', 'build/web')"
