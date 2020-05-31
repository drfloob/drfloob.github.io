build:
	cd src && \
	rm -rf public/ && \
	hugo -D && \
	cp -rf public/* ../

clean:
	ls | grep -vE "src|Makefile" | xargs rm -rf 
	rm -rf src/public
