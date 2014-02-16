bin = node_modules/.bin


lib/canon.js: src/canon.coffee
	@cat $< | $(bin)/coffee --compile --stdio > $@


.PHONY: clean
clean:
	@rm -rf lib/*
	@rm -rf node_modules


.PHONY: release
release:
ifndef VERSION
	$(error VERSION not set)
endif
	@sed -i '' 's!\("version": "\)[0-9.]*\("\)!\1$(VERSION)\2!' package.json
	@sed -i '' "s!\(= version: '\)[0-9.]*\('\)!\1$(VERSION)\2!" src/canon.coffee
	@make
	@git commit --all --message $(VERSION)
	@echo 'remember to run `npm publish`'


.PHONY: setup
setup:
	@npm install


.PHONY: test
test:
	@$(bin)/mocha test --compilers coffee:coffee-script
