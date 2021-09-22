dockers = ${wildcard docker/*.md}
dockerd = $(dockers:%.md=%)
#dockerd = ${patsubst %.md, %, $(dockers)}

golangd = ${patsubst %.md, %, ${wildcard golang/*.md golang/*/*.md}}
noted = ${patsubst %.md, %, ${wildcard note/*.md note/*/*.md}}
toolsd = ${patsubst %.md, %, ${wildcard tools/*.md}}
webd = ${patsubst %.md, %, ${wildcard web/*.md}}

.PHONY: default
default: all

.PHONY: all
all: docker golang note tools web top

.PHONY: docker
docker: clean
	@$(foreach var, $(dockerd), \
		echo "- [$(var)]($(var))" >> docker/README.md; \
	)

.PHONY: golang
golang: clean
	@$(foreach var, $(golangd), \
		echo "- [$(var)]($(var))" >> golang/README.md; \
	)

.PHONY: note
note: clean
	@$(foreach var, $(noted), \
		echo "- [$(var)]($(var))" >> note/README.md; \
	)

.PHONY: tools
tools: clean
	@$(foreach var, $(toolsd), \
		echo "- [$(var)]($(var))" >> tools/README.md; \
	)

.PHONY: web
web: clean
	@$(foreach var, $(webd), \
		echo "- [$(var)]($(var))" >> web/README.md; \
	)

.PHONY: top
top: clean
	@echo "- [home](/)" >> _navbar.md
	@echo "- [docker](docker/)" >> _navbar.md
	@echo "- [golang](golang/)" >> _navbar.md
	@echo "- [note](note/)" >> _navbar.md
	@echo "- [tools](tools/)" >> _navbar.md
	@echo "- [web](web/)" >> _navbar.md
	@echo make complete

.PHONY: clean
clean:
#	@-find -name *README.md | xargs rm
	@-find -regex './.*/README.md' | xargs rm
	@-rm _navbar.md
