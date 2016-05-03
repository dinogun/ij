.PHONY: all test clean

test:
	cd tests && ./buildAll.sh input.txt
