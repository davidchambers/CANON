COFFEE = node_modules/.bin/coffee
MOCHA = node_modules/.bin/mocha --ui qunit
XYZ = node_modules/.bin/xyz --message X.Y.Z --tag X.Y.Z --repo git@github.com:davidchambers/CANON.git --script scripts/prepublish

LIB = $(patsubst src/%.coffee,lib/%.js,$(shell find src -type f))


.PHONY: all
all: $(LIB)

lib/%.js: src/%.coffee
	$(COFFEE) --compile --output $(@D) -- $<


.PHONY: clean
clean:
	rm -f -- $(LIB)


.PHONY: release-patch release-minor release-major
release-patch: LEVEL = patch
release-minor: LEVEL = minor
release-major: LEVEL = major

release-patch release-minor release-major:
	$(XYZ) --increment $(LEVEL)


.PHONY: setup
setup:
	npm install
	make clean
	git update-index --assume-unchanged $(LIB)


.PHONY: test
test: all
	$(MOCHA)
	@echo 'open test/index.html to run tests in a browser'
